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

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'client.dart';
import 'response.dart';

/// The OAuth 2.0 token returned by Casdoor's token endpoint.
class OAuthToken {
  OAuthToken(this.json);

  final Map<String, dynamic> json;

  String get accessToken => json['access_token']?.toString() ?? '';

  /// The OpenID Connect ID token, a JWT that can be parsed by
  /// `parseJwtToken()`.
  String get idToken => json['id_token']?.toString() ?? '';

  String get refreshToken => json['refresh_token']?.toString() ?? '';

  String get tokenType => json['token_type']?.toString() ?? '';

  /// The lifetime of the access token in seconds.
  int get expiresIn => (json['expires_in'] as num?)?.toInt() ?? 0;

  String get scope => json['scope']?.toString() ?? '';
}

extension CasdoorAuthApi on CasdoorClient {
  /// Exchanges the authorization [code] that Casdoor sent to the redirect URI
  /// (`?code=...&state=...`) for a token. Then call `parseJwtToken()` with
  /// [OAuthToken.accessToken] to get the user.
  Future<OAuthToken> getOAuthToken(String code, {String? codeVerifier}) =>
      _requestOAuthToken('access_token', {
        'grant_type': 'authorization_code',
        'code': code,
        if (codeVerifier != null) 'code_verifier': codeVerifier,
      });

  /// Gets a new token with [refreshToken].
  Future<OAuthToken> refreshOAuthToken(String refreshToken, {String? scope}) =>
      _requestOAuthToken('refresh_token', {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        if (scope != null) 'scope': scope,
      });

  /// Gets a token with the user's [username] and [password] (the "Resource
  /// Owner Password Credentials" grant).
  Future<OAuthToken> getOAuthTokenByPassword(
    String username,
    String password,
  ) =>
      _requestOAuthToken('access_token', {
        'grant_type': 'password',
        'username': username,
        'password': password,
      });

  /// Gets a token for the application itself (the "Client Credentials"
  /// grant), for machine-to-machine calls.
  Future<OAuthToken> getOAuthTokenByClientCredentials() =>
      _requestOAuthToken('access_token', {
        'grant_type': 'client_credentials',
      });

  Future<OAuthToken> _requestOAuthToken(
    String action,
    Map<String, String> params,
  ) async {
    final request = http.Request('POST', getUrl('login/oauth/$action'))
      ..headers.addAll(getHeaders(withAuth: false))
      ..bodyFields = {
        'client_id': config.clientId,
        'client_secret': config.clientSecret,
        ...params,
      };

    final response =
        await http.Response.fromStream(await httpClient.send(request));
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);

    final dynamic json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      throw CasdoorException(body, statusCode: response.statusCode);
    }
    if (json is! Map<String, dynamic>) {
      throw CasdoorException(body, statusCode: response.statusCode);
    }

    // e.g. {"error": "invalid_grant", "error_description": "..."}
    final error = json['error']?.toString() ?? '';
    if (error.isNotEmpty) {
      final description = json['error_description']?.toString() ?? '';
      throw CasdoorException(
        description.isEmpty ? error : '$error: $description',
        statusCode: response.statusCode,
      );
    }

    // e.g. {"status": "error", "msg": "..."}
    if (json['status'] == 'error') {
      throw CasdoorException(json['msg']?.toString() ?? '',
          statusCode: response.statusCode);
    }

    final token = OAuthToken(json);
    // older Casdoor versions return the error in the access token
    if (token.accessToken.startsWith('error:')) {
      throw CasdoorException(token.accessToken.substring(6).trim());
    }
    if (token.accessToken.isEmpty) {
      throw CasdoorException('no access token in the response: $body',
          statusCode: response.statusCode);
    }
    return token;
  }
}
