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

import 'client.dart';

extension CasdoorUrlApi on CasdoorClient {
  /// Returns the URL of Casdoor's sign-in page. After signing in, Casdoor
  /// redirects the browser to [redirectUri] with `?code=...&state=...`, and
  /// the backend passes the code to `getOAuthToken()`.
  String getSigninUrl(String redirectUri, {String scope = 'read'}) {
    final query = {
      'client_id': config.clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': scope,
      'state': applicationName,
    };
    return Uri.parse('$endpoint/login/oauth/authorize')
        .replace(queryParameters: query)
        .toString();
  }

  /// Returns the URL of Casdoor's sign-up page. If [enablePassword] is true,
  /// it's the application's plain sign-up page and [redirectUri] isn't used,
  /// otherwise it's the OAuth sign-up page that redirects to [redirectUri].
  String getSignupUrl(bool enablePassword, String redirectUri) {
    if (enablePassword) {
      return '$endpoint/signup/$applicationName';
    }
    return getSigninUrl(redirectUri)
        .replaceFirst('/login/oauth/authorize', '/signup/oauth/authorize');
  }

  /// Returns the URL of the profile page of the user [userName].
  String getUserProfileUrl(String userName, [String accessToken = '']) =>
      '$endpoint/users/$organizationName/$userName${_tokenParam(accessToken)}';

  /// Returns the URL of the profile page of the signed-in user.
  String getMyProfileUrl([String accessToken = '']) =>
      '$endpoint/account${_tokenParam(accessToken)}';

  static String _tokenParam(String accessToken) => accessToken.isEmpty
      ? ''
      : '?access_token=${Uri.encodeQueryComponent(accessToken)}';
}
