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

class Group extends CasdoorObject {
  Group([super.json]);

  String get manager => getString('manager');
  set manager(String value) => json['manager'] = value;

  String get contactEmail => getString('contactEmail');
  set contactEmail(String value) => json['contactEmail'] = value;

  String get type => getString('type');
  set type(String value) => json['type'] = value;

  String get parentId => getString('parentId');
  set parentId(String value) => json['parentId'] = value;

  bool get isTopGroup => getBool('isTopGroup');
  set isTopGroup(bool value) => json['isTopGroup'] = value;

  List<String> get users => getStringList('users');
  set users(List<String> value) => json['users'] = value;

  bool get isEnabled => getBool('isEnabled');
  set isEnabled(bool value) => json['isEnabled'] = value;

  Map<String, String> get properties => getStringMap('properties');
  set properties(Map<String, String> value) => json['properties'] = value;
}

extension CasdoorGroupApi on CasdoorClient {
  Future<List<Group>> getGroups() =>
      getObjects('get-groups', {'owner': organizationName}, Group.new);

  /// Gets a page of groups. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Group>> getPaginationGroups(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-groups',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        Group.new,
      );

  /// Gets a group by name (or "owner/name" ID). Returns null if not found.
  Future<Group?> getGroup(String name) =>
      getObject('get-group', {'id': getId(name)}, Group.new);

  Future<bool> addGroup(Group group) =>
      modifyObject('add-group', group, organizationName);

  Future<bool> updateGroup(Group group) =>
      modifyObject('update-group', group, organizationName);

  Future<bool> updateGroupForColumns(Group group, List<String> columns) =>
      modifyObject('update-group', group, organizationName, columns: columns);

  Future<bool> deleteGroup(Group group) =>
      modifyObject('delete-group', group, organizationName);
}
