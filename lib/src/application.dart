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

class Application extends CasdoorObject {
  Application([super.json]);

  String get organization => getString('organization');
  set organization(String value) => json['organization'] = value;

  String get logo => getString('logo');
  set logo(String value) => json['logo'] = value;

  String get homepageUrl => getString('homepageUrl');
  set homepageUrl(String value) => json['homepageUrl'] = value;

  String get description => getString('description');
  set description(String value) => json['description'] = value;

  String get cert => getString('cert');
  set cert(String value) => json['cert'] = value;

  bool get enablePassword => getBool('enablePassword');
  set enablePassword(bool value) => json['enablePassword'] = value;

  bool get enableSignUp => getBool('enableSignUp');
  set enableSignUp(bool value) => json['enableSignUp'] = value;

  bool get enableCodeSignin => getBool('enableCodeSignin');
  set enableCodeSignin(bool value) => json['enableCodeSignin'] = value;

  String get clientId => getString('clientId');
  set clientId(String value) => json['clientId'] = value;

  String get clientSecret => getString('clientSecret');
  set clientSecret(String value) => json['clientSecret'] = value;

  List<String> get redirectUris => getStringList('redirectUris');
  set redirectUris(List<String> value) => json['redirectUris'] = value;

  String get tokenFormat => getString('tokenFormat');
  set tokenFormat(String value) => json['tokenFormat'] = value;

  int get expireInHours => getInt('expireInHours');
  set expireInHours(int value) => json['expireInHours'] = value;

  int get refreshExpireInHours => getInt('refreshExpireInHours');
  set refreshExpireInHours(int value) => json['refreshExpireInHours'] = value;

  String get signupUrl => getString('signupUrl');
  set signupUrl(String value) => json['signupUrl'] = value;

  String get signinUrl => getString('signinUrl');
  set signinUrl(String value) => json['signinUrl'] = value;

  String get forgetUrl => getString('forgetUrl');
  set forgetUrl(String value) => json['forgetUrl'] = value;
}

extension CasdoorApplicationApi on CasdoorClient {
  Future<List<Application>> getApplications() =>
      getObjects('get-applications', {'owner': 'admin'}, Application.new);

  /// Gets the applications of the client's organization.
  Future<List<Application>> getOrganizationApplications() => getObjects(
        'get-organization-applications',
        {'owner': 'admin', 'organization': organizationName},
        Application.new,
      );

  /// Gets a page of applications. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Application>> getPaginationApplications(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-applications',
        p,
        pageSize,
        {...query, 'owner': 'admin'},
        Application.new,
      );

  /// Gets a application by name (or "owner/name" ID). Returns null if not found.
  Future<Application?> getApplication(String name) =>
      getObject('get-application', {'id': getAdminId(name)}, Application.new);

  Future<bool> addApplication(Application application) =>
      modifyObject('add-application', application, 'admin');

  Future<bool> updateApplication(Application application) =>
      modifyObject('update-application', application, 'admin');

  Future<bool> updateApplicationForColumns(
          Application application, List<String> columns) =>
      modifyObject('update-application', application, 'admin',
          columns: columns);

  Future<bool> deleteApplication(Application application) =>
      modifyObject('delete-application', application, 'admin');
}
