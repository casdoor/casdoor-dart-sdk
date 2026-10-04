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

/// The error thrown when a Casdoor API call fails, either because the server
/// returned `"status": "error"`, or because the HTTP request itself failed.
class CasdoorException implements Exception {
  CasdoorException(this.message, {this.statusCode});

  final String message;

  /// The HTTP status code, if the error comes from a non-2xx response.
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'CasdoorException: $message'
      : 'CasdoorException($statusCode): $message';
}

/// The standard response of the Casdoor API:
/// `{"status": "ok", "msg": "", "data": ..., "data2": ...}`.
class CasdoorResponse {
  CasdoorResponse(this.json);

  final Map<String, dynamic> json;

  String get status => json['status'] as String? ?? '';
  String get msg => json['msg'] as String? ?? '';
  String get sub => json['sub'] as String? ?? '';
  String get name => json['name'] as String? ?? '';
  dynamic get data => json['data'];
  dynamic get data2 => json['data2'];
  dynamic get data3 => json['data3'];

  bool get isOk => status == 'ok';

  /// Whether an add, update or delete API actually changed something.
  bool get isAffected => data == 'Affected';
}

/// A page of objects returned by a paginated Casdoor API.
class CasdoorPage<T> {
  CasdoorPage(this.items, this.total);

  final List<T> items;

  /// The total number of objects that match the query, across all pages.
  final int total;
}
