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
import 'response.dart';

extension CasdoorNotifyApi on CasdoorClient {
  /// Sends an email with the email provider of the application, or with the
  /// email provider [provider] if it's set.
  Future<void> sendEmail(
    String title,
    String content,
    String sender,
    List<String> receivers, {
    String provider = '',
  }) async {
    await doPost(
      'send-email',
      query: provider.isEmpty ? null : {'provider': provider},
      body: {
        'title': title,
        'content': content,
        'sender': sender,
        'receivers': receivers,
      },
    );
  }

  /// Sends an SMS with the SMS provider of the application, or with the SMS
  /// provider [provider] if it's set.
  Future<void> sendSms(
    String content,
    List<String> receivers, {
    String provider = '',
  }) async {
    await doPost(
      'send-sms',
      query: provider.isEmpty ? null : {'provider': provider},
      body: {'content': content, 'receivers': receivers},
    );
  }

  /// Signs the user of [accessToken] out of Casdoor. If [logoutAll] is true,
  /// all the sessions of the user are signed out, otherwise only the current
  /// one.
  Future<void> logout(String accessToken, {bool logoutAll = true}) async {
    if (accessToken.isEmpty) {
      throw CasdoorException('the access token should not be empty');
    }

    // the "sso-logout" API identifies the user by their own access token
    await withAccessToken(accessToken).doPost(
      'sso-logout',
      query: {'logoutAll': '$logoutAll'},
    );
  }
}
