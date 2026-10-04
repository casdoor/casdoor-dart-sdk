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

/// A Casbin request, such as `['alice', 'data1', 'read']`.
typedef CasbinRequest = List<Object?>;

extension CasdoorEnforceApi on CasdoorClient {
  /// Checks a Casbin request against Casdoor's permissions. Exactly one of
  /// [permissionId], [modelId], [resourceId], [enforcerId] or [owner] should
  /// be set, see https://casdoor.org/docs/permission/exposed-casbin-apis.
  ///
  /// ```dart
  /// final allowed = await client.enforce(
  ///   permissionId: 'built-in/permission-built-in',
  ///   request: ['built-in/alice', 'data1', 'read'],
  /// );
  /// ```
  Future<bool> enforce({
    String permissionId = '',
    String modelId = '',
    String resourceId = '',
    String enforcerId = '',
    String owner = '',
    required CasbinRequest request,
  }) async {
    final response = await doPost(
      'enforce',
      query:
          _enforceQuery(permissionId, modelId, resourceId, enforcerId, owner),
      body: request,
    );

    final data = response.data;
    if (data is! List || data.any((e) => e is! bool)) {
      throw CasdoorException('invalid enforce result: $data');
    }
    // one result per permission of the model, the request is allowed if any of
    // them allows it
    return data.contains(true);
  }

  /// Checks a batch of Casbin requests. Returns one list of results per
  /// permission (or model) that was used.
  Future<List<List<bool>>> batchEnforce({
    String permissionId = '',
    String modelId = '',
    String resourceId = '',
    String enforcerId = '',
    String owner = '',
    required List<CasbinRequest> requests,
  }) async {
    final response = await doPost(
      'batch-enforce',
      query:
          _enforceQuery(permissionId, modelId, resourceId, enforcerId, owner),
      body: requests,
    );

    final data = response.data;
    if (data is! List ||
        data.any((e) => e is! List || e.any((r) => r is! bool))) {
      throw CasdoorException('invalid batch enforce result: $data');
    }
    return [for (final results in data) List<bool>.from(results as List)];
  }

  static Map<String, String> _enforceQuery(
    String permissionId,
    String modelId,
    String resourceId,
    String enforcerId,
    String owner,
  ) =>
      {
        'permissionId': permissionId,
        'modelId': modelId,
        'resourceId': resourceId,
        'enforcerId': enforcerId,
        'owner': owner,
      };
}
