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

import 'package:casdoor_dart_sdk/casdoor_dart_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const config = CasdoorConfig(
  endpoint: 'http://localhost:8000/',
  clientId: 'client-id',
  clientSecret: 'client-secret',
  certificate: '',
  organizationName: 'built-in',
  applicationName: 'app-built-in',
);

final basicAuth =
    'Basic ${base64.encode(utf8.encode('client-id:client-secret'))}';

http.Response jsonResponse(Object json, [int statusCode = 200]) =>
    http.Response(jsonEncode(json), statusCode,
        headers: {'content-type': 'application/json; charset=utf-8'});

http.Response ok(Object? data, [Object? data2]) =>
    jsonResponse({'status': 'ok', 'msg': '', 'data': data, 'data2': data2});

/// Returns a client whose requests are recorded in [requests] and answered by
/// [handler].
CasdoorClient newClient(
  List<http.Request> requests,
  http.Response Function(http.Request request) handler,
) =>
    CasdoorClient(
      config,
      httpClient: MockClient((request) async {
        requests.add(request);
        return handler(request);
      }),
      customHeaders: {'X-Custom': 'yes'},
    );

void main() {
  group('ids and urls', () {
    final client = CasdoorClient(config);

    test('getId', () {
      expect(client.getId('alice'), 'built-in/alice');
      expect(client.getId('other/alice'), 'other/alice');
      expect(client.getAdminId('built-in'), 'admin/built-in');
    });

    test('getSigninUrl', () {
      final url =
          Uri.parse(client.getSigninUrl('http://localhost:9000/callback?a=b'));
      expect(url.origin, 'http://localhost:8000');
      expect(url.path, '/login/oauth/authorize');
      expect(url.queryParameters, {
        'client_id': 'client-id',
        'response_type': 'code',
        'redirect_uri': 'http://localhost:9000/callback?a=b',
        'scope': 'read',
        'state': 'app-built-in',
      });
    });

    test('getSignupUrl', () {
      expect(client.getSignupUrl(true, ''),
          'http://localhost:8000/signup/app-built-in');
      expect(
        client.getSignupUrl(false, 'http://localhost:9000/callback'),
        startsWith(
            'http://localhost:8000/signup/oauth/authorize?client_id=client-id'),
      );
    });

    test('profile urls', () {
      expect(client.getUserProfileUrl('alice'),
          'http://localhost:8000/users/built-in/alice');
      expect(client.getMyProfileUrl('a+b'),
          'http://localhost:8000/account?access_token=a%2Bb');
    });
  });

  group('users', () {
    test('getUsers', () async {
      final requests = <http.Request>[];
      final client = newClient(
          requests,
          (_) => ok([
                {'owner': 'built-in', 'name': 'alice', 'displayName': '爱丽丝'},
                {'owner': 'built-in', 'name': 'bob'},
              ]));

      final users = await client.getUsers();

      expect(users.map((u) => u.getId()), ['built-in/alice', 'built-in/bob']);
      expect(users.first.displayName, '爱丽丝');
      final request = requests.single;
      expect(request.method, 'GET');
      expect(request.url.toString(),
          'http://localhost:8000/api/get-users?owner=built-in');
      expect(request.headers['Authorization'], basicAuth);
      expect(request.headers['X-Custom'], 'yes');
    });

    test('getUser returns null for a missing user', () async {
      final client = newClient([], (_) => ok(null));
      expect(await client.getUser('nobody'), isNull);
    });

    test('getPaginationUsers', () async {
      final requests = <http.Request>[];
      final client = newClient(
          requests,
          (_) => ok([
                {'owner': 'built-in', 'name': 'alice'},
              ], 42));

      final page = await client
          .getPaginationUsers(2, 10, {'field': 'name', 'value': 'a'});

      expect(page.items.single.name, 'alice');
      expect(page.total, 42);
      expect(requests.single.url.queryParameters, {
        'field': 'name',
        'value': 'a',
        'owner': 'built-in',
        'p': '2',
        'pageSize': '10',
      });
    });

    test('updateUser keeps the fields unknown to the SDK', () async {
      final requests = <http.Request>[];
      final client = newClient(requests, (request) {
        if (request.url.path == '/api/get-user') {
          return ok({
            'owner': 'built-in',
            'name': 'alice',
            'futureField': {'a': 1}
          });
        }
        return ok('Affected');
      });

      final user = (await client.getUser('alice'))!..displayName = 'Alice';
      final affected = await client.updateUserForColumns(user, ['displayName']);

      expect(affected, isTrue);
      final request = requests.last;
      expect(request.method, 'POST');
      expect(request.url.path, '/api/update-user');
      expect(request.url.queryParameters,
          {'id': 'built-in/alice', 'columns': 'displayName'});
      expect(jsonDecode(request.body), {
        'owner': 'built-in',
        'name': 'alice',
        'futureField': {'a': 1},
        'displayName': 'Alice',
      });
    });

    test('addUser sets the default owner', () async {
      final requests = <http.Request>[];
      final client = newClient(requests, (_) => ok('Unaffected'));

      final affected = await client.addUser(User()..name = 'carol');

      expect(affected, isFalse);
      expect(requests.single.url.queryParameters['id'], 'built-in/carol');
      expect(jsonDecode(requests.single.body)['owner'], 'built-in');
    });

    test('an error response throws', () async {
      final client = newClient(
          [],
          (_) => jsonResponse(
              {'status': 'error', 'msg': 'Unauthorized operation'}));
      expect(
        client.getUsers(),
        throwsA(isA<CasdoorException>()
            .having((e) => e.message, 'message', 'Unauthorized operation')),
      );
    });

    test('an HTTP error throws', () async {
      final client = newClient([], (_) => http.Response('Bad Gateway', 502));
      expect(
        client.getUsers(),
        throwsA(isA<CasdoorException>()
            .having((e) => e.statusCode, 'statusCode', 502)),
      );
    });

    test('setPassword sends a form', () async {
      final requests = <http.Request>[];
      final client =
          CasdoorClient(config, httpClient: MockClient((request) async {
        requests.add(request);
        return ok(null);
      }));

      expect(await client.setPassword('built-in', 'alice', '', 'new-password'),
          isTrue);
      final request = requests.single;
      expect(
          request.headers['content-type'], startsWith('multipart/form-data'));
      expect(request.body, contains('name="newPassword"\r\n\r\nnew-password'));
    });

    test('withAccessToken uses the Bearer token', () async {
      final requests = <http.Request>[];
      final client = newClient(
          requests, (_) => ok({'owner': 'built-in', 'name': 'alice'}));

      final user = await client.withAccessToken('token').getAccount();

      expect(user!.name, 'alice');
      expect(requests.single.headers['Authorization'], 'Bearer token');
      expect(requests.single.headers['X-Custom'], 'yes');
    });
  });

  group('oauth', () {
    test('getOAuthToken', () async {
      final requests = <http.Request>[];
      final client = newClient(
          requests,
          (_) => jsonResponse({
                'access_token': 'access',
                'id_token': 'id',
                'refresh_token': 'refresh',
                'token_type': 'Bearer',
                'expires_in': 7200,
                'scope': 'openid',
              }));

      final token = await client.getOAuthToken('the-code');

      expect(token.accessToken, 'access');
      expect(token.refreshToken, 'refresh');
      expect(token.expiresIn, 7200);
      final request = requests.single;
      expect(request.url.toString(),
          'http://localhost:8000/api/login/oauth/access_token');
      expect(request.bodyFields, {
        'client_id': 'client-id',
        'client_secret': 'client-secret',
        'grant_type': 'authorization_code',
        'code': 'the-code',
      });
    });

    test('refreshOAuthToken', () async {
      final requests = <http.Request>[];
      final client =
          newClient(requests, (_) => jsonResponse({'access_token': 'new'}));

      final token = await client.refreshOAuthToken('refresh');

      expect(token.accessToken, 'new');
      expect(requests.single.url.path, '/api/login/oauth/refresh_token');
      expect(requests.single.bodyFields['refresh_token'], 'refresh');
    });

    test('an OAuth error throws', () async {
      final client = newClient(
          [],
          (_) => jsonResponse({
                'error': 'invalid_grant',
                'error_description': 'authorization code has been used',
              }, 400));
      expect(
        client.getOAuthToken('used'),
        throwsA(isA<CasdoorException>().having((e) => e.message, 'message',
            'invalid_grant: authorization code has been used')),
      );
    });

    test('an error in the access token throws', () async {
      final client = newClient(
          [], (_) => jsonResponse({'access_token': 'error: invalid code'}));
      expect(
        client.getOAuthToken('bad'),
        throwsA(isA<CasdoorException>()
            .having((e) => e.message, 'message', 'invalid code')),
      );
    });

    test('introspectToken', () async {
      final client = newClient(
          [],
          (_) => jsonResponse(
              {'active': true, 'username': 'alice', 'aud': 'client-id'}));
      final result = await client.introspectToken('access');
      expect(result.active, isTrue);
      expect(result.username, 'alice');
      expect(result.aud, ['client-id']);
    });
  });

  group('enforce', () {
    test('enforce', () async {
      final requests = <http.Request>[];
      final client = newClient(requests, (_) => ok([false, true]));

      final allowed = await client.enforce(
        permissionId: 'built-in/permission-1',
        request: ['built-in/alice', 'data1', 'read'],
      );

      expect(allowed, isTrue);
      final request = requests.single;
      expect(request.url.path, '/api/enforce');
      expect(
          request.url.queryParameters['permissionId'], 'built-in/permission-1');
      expect(jsonDecode(request.body), ['built-in/alice', 'data1', 'read']);
    });

    test('batchEnforce', () async {
      final client = newClient(
          [],
          (_) => ok([
                [true, false],
              ]));
      final results = await client.batchEnforce(
        modelId: 'built-in/model-1',
        requests: [
          ['alice', 'data1', 'read'],
          ['bob', 'data1', 'write'],
        ],
      );
      expect(results, [
        [true, false],
      ]);
    });
  });

  test('logout uses the access token', () async {
    final requests = <http.Request>[];
    final client = newClient(requests, (_) => ok(null));

    await client.logout('token', logoutAll: false);

    final request = requests.single;
    expect(request.url.toString(),
        'http://localhost:8000/api/sso-logout?logoutAll=false');
    expect(request.headers['Authorization'], 'Bearer token');
  });

  test('roles and organizations use their own owners', () async {
    final requests = <http.Request>[];
    final client = newClient(requests, (_) => ok('Affected'));

    await client.addRole(Role()
      ..name = 'admins'
      ..users = ['built-in/alice']);
    await client.updateOrganization(Organization()..name = 'built-in');
    await client.getApplication('app-built-in');

    expect(requests[0].url.queryParameters['id'], 'built-in/admins');
    expect(requests[1].url.queryParameters['id'], 'admin/built-in');
    expect(requests[2].url.queryParameters['id'], 'admin/app-built-in');
  });
}
