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

import 'dart:convert' show jsonDecode;

import 'package:http/http.dart' as http;

import 'client.dart';
import 'object.dart';
import 'response.dart';

class Token extends CasdoorObject {
  Token([super.json]);

  String get application => getString('application');
  set application(String value) => json['application'] = value;

  String get organization => getString('organization');
  set organization(String value) => json['organization'] = value;

  String get user => getString('user');
  set user(String value) => json['user'] = value;

  String get code => getString('code');
  set code(String value) => json['code'] = value;

  String get accessToken => getString('accessToken');
  set accessToken(String value) => json['accessToken'] = value;

  String get refreshToken => getString('refreshToken');
  set refreshToken(String value) => json['refreshToken'] = value;

  String get idToken => getString('idToken');
  set idToken(String value) => json['idToken'] = value;

  int get expiresIn => getInt('expiresIn');
  set expiresIn(int value) => json['expiresIn'] = value;

  String get scope => getString('scope');
  set scope(String value) => json['scope'] = value;

  String get tokenType => getString('tokenType');
  set tokenType(String value) => json['tokenType'] = value;

  String get grantType => getString('grantType');
  set grantType(String value) => json['grantType'] = value;
}

extension CasdoorTokenApi on CasdoorClient {
  Future<List<Token>> getTokens() =>
      getObjects('get-tokens', {'owner': 'admin'}, Token.new);

  /// Gets a page of tokens. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Token>> getPaginationTokens(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-tokens',
        p,
        pageSize,
        {...query, 'owner': 'admin'},
        Token.new,
      );

  /// Gets a token by name (or "owner/name" ID). Returns null if not found.
  Future<Token?> getToken(String name) =>
      getObject('get-token', {'id': getAdminId(name)}, Token.new);

  Future<bool> addToken(Token token) =>
      modifyObject('add-token', token, 'admin');

  Future<bool> updateToken(Token token) =>
      modifyObject('update-token', token, 'admin');

  Future<bool> updateTokenForColumns(Token token, List<String> columns) =>
      modifyObject('update-token', token, 'admin', columns: columns);

  Future<bool> deleteToken(Token token) =>
      modifyObject('delete-token', token, 'admin');

  /// Checks whether [token] (an access token or a refresh token) is active,
  /// see RFC 7662. [tokenTypeHint] can be `access_token` or `refresh_token`.
  Future<IntrospectTokenResult> introspectToken(
    String token, [
    String tokenTypeHint = 'access_token',
  ]) async {
    final request = http.MultipartRequest(
      'POST',
      getUrl('login/oauth/introspect'),
    )
      ..fields['token'] = token
      ..fields['token_type_hint'] = tokenTypeHint
      ..headers.addAll(getHeaders());
    final body = await send(request);
    return IntrospectTokenResult(
      Map<String, dynamic>.from(jsonDecode(body) as Map),
    );
  }
}

/// The result of [CasdoorTokenApi.introspectToken].
class IntrospectTokenResult {
  IntrospectTokenResult(this.json);

  final Map<String, dynamic> json;

  bool get active => json['active'] == true;
  String get clientId => json['client_id']?.toString() ?? '';
  String get username => json['username']?.toString() ?? '';
  String get tokenType => json['token_type']?.toString() ?? '';
  int get exp => (json['exp'] as num?)?.toInt() ?? 0;
  int get iat => (json['iat'] as num?)?.toInt() ?? 0;
  int get nbf => (json['nbf'] as num?)?.toInt() ?? 0;
  String get sub => json['sub']?.toString() ?? '';
  List<String> get aud => switch (json['aud']) {
        List list => list.map((e) => e.toString()).toList(),
        String aud => [aud],
        _ => [],
      };
  String get iss => json['iss']?.toString() ?? '';
  String get jti => json['jti']?.toString() ?? '';
}
