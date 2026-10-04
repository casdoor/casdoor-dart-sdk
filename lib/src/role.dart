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

class Role extends CasdoorObject {
  Role([super.json]);

  String get description => getString('description');
  set description(String value) => json['description'] = value;

  List<String> get users => getStringList('users');
  set users(List<String> value) => json['users'] = value;

  List<String> get groups => getStringList('groups');
  set groups(List<String> value) => json['groups'] = value;

  List<String> get roles => getStringList('roles');
  set roles(List<String> value) => json['roles'] = value;

  List<String> get domains => getStringList('domains');
  set domains(List<String> value) => json['domains'] = value;

  bool get isEnabled => getBool('isEnabled');
  set isEnabled(bool value) => json['isEnabled'] = value;
}

extension CasdoorRoleApi on CasdoorClient {
  Future<List<Role>> getRoles() =>
      getObjects('get-roles', {'owner': organizationName}, Role.new);

  /// Gets a page of roles. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Role>> getPaginationRoles(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-roles',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        Role.new,
      );

  /// Gets a role by name (or "owner/name" ID). Returns null if not found.
  Future<Role?> getRole(String name) =>
      getObject('get-role', {'id': getId(name)}, Role.new);

  Future<bool> addRole(Role role) =>
      modifyObject('add-role', role, organizationName);

  Future<bool> updateRole(Role role) =>
      modifyObject('update-role', role, organizationName);

  Future<bool> updateRoleForColumns(Role role, List<String> columns) =>
      modifyObject('update-role', role, organizationName, columns: columns);

  Future<bool> deleteRole(Role role) =>
      modifyObject('delete-role', role, organizationName);
}
