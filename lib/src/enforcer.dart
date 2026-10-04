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
import 'object.dart';
import 'response.dart';

class Enforcer extends CasdoorObject {
  Enforcer([super.json]);

  String get description => getString('description');
  set description(String value) => json['description'] = value;

  String get model => getString('model');
  set model(String value) => json['model'] = value;

  String get adapter => getString('adapter');
  set adapter(String value) => json['adapter'] = value;
}

extension CasdoorEnforcerApi on CasdoorClient {
  Future<List<Enforcer>> getEnforcers() =>
      getObjects('get-enforcers', {'owner': organizationName}, Enforcer.new);

  /// Gets a page of enforcers. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Enforcer>> getPaginationEnforcers(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-enforcers',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        Enforcer.new,
      );

  /// Gets a enforcer by name (or "owner/name" ID). Returns null if not found.
  Future<Enforcer?> getEnforcer(String name) =>
      getObject('get-enforcer', {'id': getId(name)}, Enforcer.new);

  Future<bool> addEnforcer(Enforcer enforcer) =>
      modifyObject('add-enforcer', enforcer, organizationName);

  Future<bool> updateEnforcer(Enforcer enforcer) =>
      modifyObject('update-enforcer', enforcer, organizationName);

  Future<bool> updateEnforcerForColumns(
          Enforcer enforcer, List<String> columns) =>
      modifyObject('update-enforcer', enforcer, organizationName,
          columns: columns);

  Future<bool> deleteEnforcer(Enforcer enforcer) =>
      modifyObject('delete-enforcer', enforcer, organizationName);
}
