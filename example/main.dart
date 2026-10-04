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

// A minimal Dart backend that signs users in with Casdoor, using only dart:io.
// The same calls work in Shelf, Dart Frog, Serverpod, etc.
//
// Add http://localhost:9000/callback to the "Redirect URLs" of the Casdoor
// application, then run:
//
//   CASDOOR_CLIENT_SECRET=... dart run example/main.dart

import 'dart:io';

import 'package:casdoor_dart_sdk/casdoor_dart_sdk.dart';

const certificate = '''-----BEGIN CERTIFICATE-----
...the certificate of the application's cert...
-----END CERTIFICATE-----''';

Future<void> main() async {
  final client = CasdoorClient(CasdoorConfig(
    endpoint: 'http://localhost:8000',
    clientId: 'your-client-id',
    clientSecret: Platform.environment['CASDOOR_CLIENT_SECRET'] ?? '',
    certificate: certificate,
    organizationName: 'built-in',
    applicationName: 'app-built-in',
  ));
  const redirectUri = 'http://localhost:9000/callback';

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 9000);
  print('Open http://localhost:9000/login');

  await for (final request in server) {
    final response = request.response;
    try {
      switch (request.uri.path) {
        case '/login':
          // 1. redirect the browser to Casdoor's sign-in page
          await response.redirect(Uri.parse(client.getSigninUrl(redirectUri)));
          continue;

        case '/callback':
          // 2. Casdoor redirects back with ?code=...&state=...
          final code = request.uri.queryParameters['code'] ?? '';
          final token = await client.getOAuthToken(code);

          // 3. verify the access token and get the user from it
          final claims = client.parseJwtToken(token.accessToken);
          response.write('Hello, ${claims.displayName} (${claims.getId()})\n');

          // 4. call the Casdoor API, for example to check a permission
          final allowed = await client.enforce(
            permissionId: 'built-in/permission-built-in',
            request: [claims.getId(), 'app-built-in', 'Read'],
          );
          response.write('Read app-built-in: $allowed\n');

        default:
          response.statusCode = HttpStatus.notFound;
      }
    } on CasdoorException catch (e) {
      response
        ..statusCode = HttpStatus.unauthorized
        ..write(e.message);
    }
    await response.close();
  }
}
