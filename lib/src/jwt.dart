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

import 'dart:convert' show base64Url, jsonDecode, utf8;

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'client.dart';
import 'response.dart';
import 'user.dart';

/// The claims of a JWT token issued by Casdoor: the user, plus the standard
/// JWT claims.
class Claims extends User {
  Claims([super.json]);

  /// "access-token", "refresh-token" or "id-token". Casdoor emits the claim
  /// as "tokenType" for the JWT, JWT-Empty and JWT-Standard token formats, and
  /// as "TokenType" for JWT-Custom.
  String get tokenType =>
      json['tokenType']?.toString() ?? json['TokenType']?.toString() ?? '';

  bool get isRefreshToken => tokenType == 'refresh-token';

  String get nonce => getString('nonce');

  String get scope => getString('scope');

  /// The `azp` (Authorized Party) claim, the client ID of the application.
  String get azp => getString('azp');

  String get provider => getString('provider');

  String get signinMethod => getString('signinMethod');

  String get iss => getString('iss');

  String get sub => getString('sub');

  List<String> get aud => switch (json['aud']) {
        List list => list.map((e) => e.toString()).toList(),
        String aud => [aud],
        _ => [],
      };

  String get jti => getString('jti');

  DateTime? get expiresAt => _time('exp');

  DateTime? get issuedAt => _time('iat');

  DateTime? get notBefore => _time('nbf');

  DateTime? _time(String key) {
    final value = json[key];
    return value is num
        ? DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt(),
            isUtc: true)
        : null;
  }
}

extension CasdoorJwtApi on CasdoorClient {
  /// Verifies a JWT [token] issued by Casdoor (an access token, refresh token
  /// or ID token) with the configured certificate, and returns its claims.
  /// Throws a [CasdoorException] if the token is invalid or expired.
  Claims parseJwtToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw CasdoorException('invalid JWT token');
    }

    final String alg;
    try {
      final header = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[0]))),
      );
      alg = (header as Map)['alg'] as String;
    } catch (_) {
      throw CasdoorException('invalid JWT token header');
    }

    // the algorithm must be pinned, otherwise a token could pick one that
    // isn't meant to be used with the certificate, such as "none" or "HS256"
    if (!config.jwtAlgorithms.contains(alg)) {
      throw CasdoorException('unsupported signing method: $alg');
    }

    try {
      final jwt = JWT.verify(token, _getPublicKey(alg), checkHeaderType: false);
      final payload = jwt.payload;
      if (payload is! Map) {
        throw CasdoorException('invalid JWT token payload');
      }
      return Claims(Map<String, dynamic>.from(payload));
    } on JWTExpiredException {
      throw CasdoorException('the JWT token is expired');
    } on JWTException catch (e) {
      throw CasdoorException('invalid JWT token: ${e.message}');
    }
  }

  JWTKey _getPublicKey(String alg) {
    final pem = config.certificate.trim();
    final isCert = pem.contains('CERTIFICATE');
    try {
      if (alg.startsWith('ES')) {
        return isCert ? ECPublicKey.cert(pem) : ECPublicKey(pem);
      }
      return isCert ? RSAPublicKey.cert(pem) : RSAPublicKey(pem);
    } catch (e) {
      throw CasdoorException('invalid certificate for $alg: $e');
    }
  }
}
