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

class Organization extends CasdoorObject {
  Organization([super.json]);

  String get websiteUrl => getString('websiteUrl');
  set websiteUrl(String value) => json['websiteUrl'] = value;

  String get logo => getString('logo');
  set logo(String value) => json['logo'] = value;

  String get favicon => getString('favicon');
  set favicon(String value) => json['favicon'] = value;

  String get passwordType => getString('passwordType');
  set passwordType(String value) => json['passwordType'] = value;

  String get passwordSalt => getString('passwordSalt');
  set passwordSalt(String value) => json['passwordSalt'] = value;

  List<String> get countryCodes => getStringList('countryCodes');
  set countryCodes(List<String> value) => json['countryCodes'] = value;

  String get defaultAvatar => getString('defaultAvatar');
  set defaultAvatar(String value) => json['defaultAvatar'] = value;

  String get defaultApplication => getString('defaultApplication');
  set defaultApplication(String value) => json['defaultApplication'] = value;

  List<String> get tags => getStringList('tags');
  set tags(List<String> value) => json['tags'] = value;

  List<String> get languages => getStringList('languages');
  set languages(List<String> value) => json['languages'] = value;

  String get masterPassword => getString('masterPassword');
  set masterPassword(String value) => json['masterPassword'] = value;

  int get initScore => getInt('initScore');
  set initScore(int value) => json['initScore'] = value;

  bool get enableSoftDeletion => getBool('enableSoftDeletion');
  set enableSoftDeletion(bool value) => json['enableSoftDeletion'] = value;

  bool get isProfilePublic => getBool('isProfilePublic');
  set isProfilePublic(bool value) => json['isProfilePublic'] = value;
}

extension CasdoorOrganizationApi on CasdoorClient {
  Future<List<Organization>> getOrganizations() =>
      getObjects('get-organizations', {'owner': 'admin'}, Organization.new);

  /// Gets a page of organizations. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Organization>> getPaginationOrganizations(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-organizations',
        p,
        pageSize,
        {...query, 'owner': 'admin'},
        Organization.new,
      );

  /// Gets a organization by name (or "owner/name" ID). Returns null if not found.
  Future<Organization?> getOrganization(String name) =>
      getObject('get-organization', {'id': getAdminId(name)}, Organization.new);

  Future<bool> addOrganization(Organization organization) =>
      modifyObject('add-organization', organization, 'admin');

  Future<bool> updateOrganization(Organization organization) =>
      modifyObject('update-organization', organization, 'admin');

  Future<bool> updateOrganizationForColumns(
          Organization organization, List<String> columns) =>
      modifyObject('update-organization', organization, 'admin',
          columns: columns);

  Future<bool> deleteOrganization(Organization organization) =>
      modifyObject('delete-organization', organization, 'admin');
}
