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

class Permission extends CasdoorObject {
  Permission([super.json]);

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

  String get model => getString('model');
  set model(String value) => json['model'] = value;

  String get adapter => getString('adapter');
  set adapter(String value) => json['adapter'] = value;

  String get resourceType => getString('resourceType');
  set resourceType(String value) => json['resourceType'] = value;

  List<String> get resources => getStringList('resources');
  set resources(List<String> value) => json['resources'] = value;

  List<String> get actions => getStringList('actions');
  set actions(List<String> value) => json['actions'] = value;

  String get effect => getString('effect');
  set effect(String value) => json['effect'] = value;

  bool get isEnabled => getBool('isEnabled');
  set isEnabled(bool value) => json['isEnabled'] = value;

  String get submitter => getString('submitter');
  set submitter(String value) => json['submitter'] = value;

  String get approver => getString('approver');
  set approver(String value) => json['approver'] = value;

  String get approveTime => getString('approveTime');
  set approveTime(String value) => json['approveTime'] = value;

  String get state => getString('state');
  set state(String value) => json['state'] = value;
}

extension CasdoorPermissionApi on CasdoorClient {
  Future<List<Permission>> getPermissions() => getObjects(
      'get-permissions', {'owner': organizationName}, Permission.new);

  /// Gets the permissions that the role [name] (or "owner/name" ID) is
  /// granted.
  Future<List<Permission>> getPermissionsByRole(String name) => getObjects(
        'get-permissions-by-role',
        {'id': getId(name)},
        Permission.new,
      );

  /// Gets a page of permissions. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Permission>> getPaginationPermissions(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-permissions',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        Permission.new,
      );

  /// Gets a permission by name (or "owner/name" ID). Returns null if not found.
  Future<Permission?> getPermission(String name) =>
      getObject('get-permission', {'id': getId(name)}, Permission.new);

  Future<bool> addPermission(Permission permission) =>
      modifyObject('add-permission', permission, organizationName);

  Future<bool> updatePermission(Permission permission) =>
      modifyObject('update-permission', permission, organizationName);

  Future<bool> updatePermissionForColumns(
          Permission permission, List<String> columns) =>
      modifyObject('update-permission', permission, organizationName,
          columns: columns);

  Future<bool> deletePermission(Permission permission) =>
      modifyObject('delete-permission', permission, organizationName);
}
