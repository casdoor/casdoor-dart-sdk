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

import 'config.dart';
import 'object.dart';
import 'response.dart';

/// The client of the Casdoor API.
///
/// All the API methods (`getUsers()`, `enforce()`, `getOAuthToken()`, ...) are
/// defined as extensions of this class, one file per object type, and are
/// available after importing `package:casdoor_dart_sdk/casdoor_dart_sdk.dart`.
class CasdoorClient {
  /// Creates a client that calls the Casdoor API as the application, using
  /// the client ID and client secret of [config].
  ///
  /// A custom [httpClient] can be passed, for example to trust a self-signed
  /// certificate (via `IOClient(HttpClient(context: ...))`) or to add a proxy.
  CasdoorClient(
    this.config, {
    http.Client? httpClient,
    Map<String, String>? customHeaders,
    this.accessToken = '',
  })  : httpClient = httpClient ?? http.Client(),
        customHeaders = {...?customHeaders};

  final CasdoorConfig config;

  final http.Client httpClient;

  /// The headers added to every request sent by this client.
  final Map<String, String> customHeaders;

  /// The user's access token. If it's not empty, all the API requests sent by
  /// this client are authenticated as the user who owns the access token (via
  /// the "Authorization: Bearer" header), instead of as the application itself
  /// (via the client ID and client secret's Basic Auth).
  /// Use [withAccessToken] to get such a client.
  final String accessToken;

  String get endpoint => config.endpoint.endsWith('/')
      ? config.endpoint.substring(0, config.endpoint.length - 1)
      : config.endpoint;

  String get organizationName => config.organizationName;

  String get applicationName => config.applicationName;

  /// Returns a client that calls the API as the user who owns [accessToken].
  /// It shares the HTTP client of this one.
  ///
  /// ```dart
  /// final user = await client.withAccessToken(token.accessToken).getAccount();
  /// ```
  CasdoorClient withAccessToken(String accessToken) => CasdoorClient(
        config,
        httpClient: httpClient,
        customHeaders: customHeaders,
        accessToken: accessToken,
      );

  /// Closes the underlying HTTP client. Clients returned by [withAccessToken]
  /// share it, so they can't be used afterwards either.
  void close() => httpClient.close();

  /// Returns the URL of the Casdoor API [action], such as `get-users`.
  Uri getUrl(String action, [Map<String, String>? query]) {
    final url = Uri.parse('$endpoint/api/$action');
    if (query == null || query.isEmpty) {
      return url;
    }
    return url.replace(queryParameters: query);
  }

  /// Returns the Casdoor ID ("owner/name") of an object owned by the
  /// organization of this client. If [name] is already a qualified
  /// "owner/name" ID, it's returned as-is, so that a client can also address
  /// objects that live outside of its own organization.
  String getId(String name) => _getId(name, organizationName);

  /// [getId] for the object types that are owned by "admin" instead of by an
  /// organization: organization, application and token.
  String getAdminId(String name) => _getId(name, 'admin');

  static String _getId(String name, String defaultOwner) =>
      name.contains('/') ? name : '$defaultOwner/$name';

  Map<String, String> getHeaders({bool withAuth = true}) {
    final headers = <String, String>{};
    if (withAuth) {
      headers['Authorization'] = accessToken.isNotEmpty
          ? 'Bearer $accessToken'
          : 'Basic ${base64.encode(utf8.encode('${config.clientId}:${config.clientSecret}'))}';
    }
    headers.addAll(customHeaders);
    return headers;
  }

  /// Sends [request] and returns the response body. Throws a
  /// [CasdoorException] if the response isn't 200 (or 403, which Casdoor uses
  /// together with an error message in the body).
  Future<String> send(http.BaseRequest request) async {
    final response = await http.Response.fromStream(
      await httpClient.send(request),
    );
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (response.statusCode != 200 && response.statusCode != 403) {
      throw CasdoorException(
        '${response.reasonPhrase ?? ''}: $body',
        statusCode: response.statusCode,
      );
    }
    return body;
  }

  /// Parses a standard Casdoor API response, and throws a [CasdoorException]
  /// if its status isn't "ok".
  CasdoorResponse parseResponse(String body) {
    final dynamic json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      throw CasdoorException('invalid response: $body');
    }
    if (json is! Map<String, dynamic>) {
      throw CasdoorException('invalid response: $body');
    }

    final response = CasdoorResponse(json);
    if (!response.isOk) {
      throw CasdoorException(response.msg);
    }
    return response;
  }

  /// Calls the Casdoor API [action] with HTTP GET.
  Future<CasdoorResponse> doGet(
    String action, [
    Map<String, String>? query,
  ]) async {
    final request = http.Request('GET', getUrl(action, query))
      ..headers.addAll(getHeaders());
    return parseResponse(await send(request));
  }

  /// Calls the Casdoor API [action] with HTTP POST. [body] is sent as JSON,
  /// or [fields] as a multipart form.
  Future<CasdoorResponse> doPost(
    String action, {
    Map<String, String>? query,
    Object? body,
    Map<String, String>? fields,
  }) async {
    final url = getUrl(action, query);
    final http.BaseRequest request;
    if (fields != null) {
      request = http.MultipartRequest('POST', url)..fields.addAll(fields);
    } else {
      request = http.Request('POST', url)
        ..headers['Content-Type'] = 'text/plain;charset=UTF-8'
        ..bodyBytes = body == null ? [] : utf8.encode(jsonEncode(body));
    }
    request.headers.addAll(getHeaders());
    return parseResponse(await send(request));
  }

  /// Gets a list of objects with the API [action], such as `get-users`.
  Future<List<T>> getObjects<T>(
    String action,
    Map<String, String> query,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final response = await doGet(action, query);
    return _toObjects(response.data, fromJson);
  }

  /// Gets a page of objects with the API [action], such as `get-users`.
  /// [p] starts from 1.
  Future<CasdoorPage<T>> getPaginationObjects<T>(
    String action,
    int p,
    int pageSize,
    Map<String, String> query,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final response = await doGet(action, {
      ...query,
      'p': '$p',
      'pageSize': '$pageSize',
    });
    return CasdoorPage(
      _toObjects(response.data, fromJson),
      (response.data2 as num?)?.toInt() ?? 0,
    );
  }

  /// Gets an object with the API [action], such as `get-user`. Returns null if
  /// the object doesn't exist.
  Future<T?> getObject<T>(
    String action,
    Map<String, String> query,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final response = await doGet(action, query);
    final data = response.data;
    return data is Map ? fromJson(Map<String, dynamic>.from(data)) : null;
  }

  /// Adds, updates or deletes [object] with the API [action], such as
  /// `update-user`. The owner of [object] defaults to [defaultOwner].
  /// If [columns] isn't empty, only these columns are updated.
  /// Returns whether the object was affected.
  Future<bool> modifyObject(
    String action,
    CasdoorObject object,
    String defaultOwner, {
    List<String>? columns,
    String? id,
  }) async {
    if (object.owner.isEmpty) {
      object.owner = defaultOwner;
    }

    final response = await doPost(
      action,
      query: {
        'id': id ?? object.getId(),
        if (columns != null && columns.isNotEmpty) 'columns': columns.join(','),
      },
      body: object.toJson(),
    );
    return response.isAffected;
  }

  static List<T> _toObjects<T>(
    dynamic data,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (data is! List) {
      return [];
    }
    return data
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
