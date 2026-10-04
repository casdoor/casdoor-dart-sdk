# casdoor-dart-sdk

[![CI](https://github.com/casdoor/casdoor-dart-sdk/actions/workflows/ci.yml/badge.svg)](https://github.com/casdoor/casdoor-dart-sdk/actions/workflows/ci.yml)
[![Pub Version](https://img.shields.io/pub/v/casdoor_dart_sdk.svg?logo=dart)](https://pub.dev/packages/casdoor_dart_sdk)
[![Pub Points](https://img.shields.io/pub/points/casdoor_dart_sdk?logo=dart)](https://pub.dev/packages/casdoor_dart_sdk/score)
[![Pub Likes](https://img.shields.io/pub/likes/casdoor_dart_sdk?logo=dart)](https://pub.dev/packages/casdoor_dart_sdk/score)
[![Pub Downloads](https://img.shields.io/pub/dm/casdoor_dart_sdk?logo=dart)](https://pub.dev/packages/casdoor_dart_sdk)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.4-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/github/license/casdoor/casdoor-dart-sdk?color=lightgray)](LICENSE)
[![Discord](https://img.shields.io/discord/1022748306096537660?logo=discord&label=discord&color=5865F2)](https://discord.gg/5rPsrAzK7S)

Casdoor's SDK for Dart **backends**: connect a server written in Dart ([Shelf](https://pub.dev/packages/shelf), [Dart Frog](https://dartfrog.vgv.dev), [Serverpod](https://serverpod.dev), plain `dart:io`, ...) to Casdoor without implementing OAuth and the Casdoor API from scratch.

For Flutter apps and Dart frontends, use [casdoor-flutter-sdk](https://github.com/casdoor/casdoor-flutter-sdk) instead.

## Installation

```shell
dart pub add casdoor_dart_sdk
```

## Step 1. Init the client

| Name             | Must | Description                                                         |
|------------------|------|---------------------------------------------------------------------|
| endpoint         | Yes  | Casdoor server URL, such as `http://localhost:8000`                 |
| clientId         | Yes  | Client ID of the Casdoor application                                |
| clientSecret     | Yes  | Client secret of the Casdoor application                            |
| certificate      | Yes  | x509 certificate (or public key) of the application's cert, in PEM  |
| organizationName | Yes  | Name of the Casdoor organization                                    |
| applicationName  | No   | Name of the Casdoor application                                     |
| jwtAlgorithms    | No   | JWT algorithms accepted by `parseJwtToken()`, defaults to RS256/384/512, PS256/384/512 and ES256/384/512 |

```dart
import 'package:casdoor_dart_sdk/casdoor_dart_sdk.dart';

final client = CasdoorClient(CasdoorConfig(
  endpoint: 'http://localhost:8000',
  clientId: '<client id>',
  clientSecret: '<client secret>',
  certificate: '''-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----''',
  organizationName: 'built-in',
  applicationName: 'app-built-in',
));
```

A custom `http.Client` can be passed with `CasdoorClient(config, httpClient: ...)`, for example to trust a self-signed certificate or to use a proxy.

## Step 2. Sign users in

```dart
// 1. redirect the browser to Casdoor's sign-in page
final url = client.getSigninUrl('http://localhost:9000/callback');

// 2. Casdoor redirects back to /callback?code=...&state=...
final token = await client.getOAuthToken(code);

// 3. verify the access token and get the user from it
final claims = client.parseJwtToken(token.accessToken);
print('${claims.getId()} ${claims.displayName} ${claims.email}');

// refresh the token later
final newToken = await client.refreshOAuthToken(token.refreshToken);

// sign the user out of Casdoor
await client.logout(token.accessToken);
```

`parseJwtToken()` throws a `CasdoorException` if the token is invalid, expired, or signed with an algorithm not in `jwtAlgorithms`.

Other grants: `getOAuthTokenByPassword(username, password)` and `getOAuthTokenByClientCredentials()`. `introspectToken(token)` checks whether a token is still active.

See [example/main.dart](example/main.dart) for a complete backend.

## Step 3. Call the Casdoor API

The client calls the API as the application (with its client ID and secret). Use `client.withAccessToken(accessToken)` to call it as a user instead.

```dart
// users
final users = await client.getUsers();
final alice = await client.getUser('alice'); // null if not found
final me = await client.withAccessToken(token.accessToken).getAccount();

await client.addUser(User()
  ..name = 'bob'
  ..displayName = 'Bob'
  ..email = 'bob@example.com'
  ..password = '123456');

alice!.displayName = 'Alice';
await client.updateUserForColumns(alice, ['displayName']);
await client.setPassword('built-in', 'alice', '', 'new-password');
await client.deleteUser(alice);

// permissions
final allowed = await client.enforce(
  permissionId: 'built-in/permission-built-in',
  request: ['built-in/alice', 'app-built-in', 'Read'],
);
```

Objects keep all the JSON returned by Casdoor, so fields that the SDK has no getter for can be read and written with `object['field']`, and an update never drops them.

| Object        | Methods                                                                                                                                                                                             |
|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| User          | `getUsers`, `getGlobalUsers`, `getSortedUsers`, `getPaginationUsers`, `getUserCount`, `getUser`, `getUserByEmail`, `getUserByPhone`, `getUserByUserId`, `getAccount`, `addUser`, `updateUser`, `updateUserForColumns`, `updateUserById`, `deleteUser`, `setPassword`, `checkUserPassword` |
| Organization, Application, Role, Permission, Group, Token, Cert, Provider, Model, Adapter, Enforcer, Webhook | `getXs`, `getPaginationXs`, `getX`, `addX`, `updateX`, `updateXForColumns`, `deleteX`, plus `getOrganizationApplications`, `getPermissionsByRole` and `introspectToken` |
| Casbin        | `enforce`, `batchEnforce`                                                                                                                                                                           |
| Notification  | `sendEmail`, `sendSms`                                                                                                                                                                              |
| URL           | `getSigninUrl`, `getSignupUrl`, `getUserProfileUrl`, `getMyProfileUrl`                                                                                                                              |

Errors returned by Casdoor (`"status": "error"`) and failed HTTP requests are thrown as `CasdoorException`.

## License

[Apache-2.0](LICENSE)
