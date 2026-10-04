// Copyright 2026 The Casdoor Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:casdoor_dart_sdk/casdoor_dart_sdk.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:test/test.dart';

String readData(String name) => File('test/data/$name').readAsStringSync();

CasdoorClient newClient(String certificate) => CasdoorClient(CasdoorConfig(
      endpoint: 'http://localhost:8000',
      clientId: 'client-id',
      clientSecret: 'client-secret',
      certificate: certificate,
      organizationName: 'built-in',
      applicationName: 'app-built-in',
    ));

Map<String, dynamic> userClaims(
    {Duration expiresIn = const Duration(hours: 1)}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return {
    'owner': 'built-in',
    'name': 'alice',
    'displayName': 'Alice',
    'email': 'alice@example.com',
    'isAdmin': true,
    'groups': ['built-in/dev'],
    'properties': {'team': 'sdk'},
    'tokenType': 'access-token',
    'iss': 'http://localhost:8000',
    'sub': 'f9c3e6a2',
    'aud': ['client-id'],
    'iat': now,
    'nbf': now,
    'exp': now + expiresIn.inSeconds,
  };
}

void main() {
  final rsaKey = RSAPrivateKey(readData('rsa_key.pem'));
  final ecKey = ECPrivateKey(readData('ec_key.pem'));

  test('parses an RS256 token', () {
    final token = JWT(userClaims()).sign(rsaKey, algorithm: JWTAlgorithm.RS256);
    final claims = newClient(readData('rsa_cert.pem')).parseJwtToken(token);

    expect(claims.getId(), 'built-in/alice');
    expect(claims.displayName, 'Alice');
    expect(claims.email, 'alice@example.com');
    expect(claims.isAdmin, isTrue);
    expect(claims.groups, ['built-in/dev']);
    expect(claims.properties, {'team': 'sdk'});
    expect(claims.tokenType, 'access-token');
    expect(claims.isRefreshToken, isFalse);
    expect(claims.aud, ['client-id']);
    expect(claims.expiresAt!.isAfter(DateTime.now()), isTrue);
  });

  test('parses an RS512 token with a public key instead of a certificate', () {
    final token = JWT(userClaims()).sign(rsaKey, algorithm: JWTAlgorithm.RS512);
    final claims = newClient(readData('rsa_public.pem')).parseJwtToken(token);
    expect(claims.name, 'alice');
  });

  test('parses an ES256 token', () {
    final token = JWT(userClaims()).sign(ecKey, algorithm: JWTAlgorithm.ES256);
    final claims = newClient(readData('ec_cert.pem')).parseJwtToken(token);
    expect(claims.name, 'alice');
  });

  test('reads "TokenType" of the JWT-Custom format', () {
    final token = JWT({
      ...userClaims()..remove('tokenType'),
      'TokenType': 'refresh-token'
    }).sign(rsaKey, algorithm: JWTAlgorithm.RS256);
    final claims = newClient(readData('rsa_cert.pem')).parseJwtToken(token);
    expect(claims.isRefreshToken, isTrue);
  });

  test('rejects an expired token', () {
    final token = JWT(userClaims(expiresIn: const Duration(hours: -1)))
        .sign(rsaKey, algorithm: JWTAlgorithm.RS256);
    expect(
      () => newClient(readData('rsa_cert.pem')).parseJwtToken(token),
      throwsA(isA<CasdoorException>()
          .having((e) => e.message, 'message', contains('expired'))),
    );
  });

  test('rejects a token signed by another key', () {
    final token = JWT(userClaims()).sign(rsaKey, algorithm: JWTAlgorithm.RS256);
    expect(
      () => newClient(readData('ec_cert.pem')).parseJwtToken(token),
      throwsA(isA<CasdoorException>()),
    );
  });

  test('rejects a tampered token', () {
    final token = JWT(userClaims()).sign(rsaKey, algorithm: JWTAlgorithm.RS256);
    final parts = token.split('.');
    final forged = JWT({...userClaims(), 'name': 'admin'})
        .sign(rsaKey, algorithm: JWTAlgorithm.RS256)
        .split('.');
    expect(
      () => newClient(readData('rsa_cert.pem'))
          .parseJwtToken('${parts[0]}.${forged[1]}.${parts[2]}'),
      throwsA(isA<CasdoorException>()),
    );
  });

  test('rejects an HS256 token signed with the certificate as the secret', () {
    final certificate = readData('rsa_cert.pem');
    final token = JWT(userClaims())
        .sign(SecretKey(certificate), algorithm: JWTAlgorithm.HS256);
    expect(
      () => newClient(certificate).parseJwtToken(token),
      throwsA(isA<CasdoorException>().having(
          (e) => e.message, 'message', contains('unsupported signing method'))),
    );
  });

  test('rejects an unsigned token', () {
    expect(
      () => newClient(readData('rsa_cert.pem')).parseJwtToken(
          'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJuYW1lIjoiYWRtaW4ifQ.'),
      throwsA(isA<CasdoorException>()),
    );
  });
}
