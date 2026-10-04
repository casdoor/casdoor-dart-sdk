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
import 'permission.dart';
import 'response.dart';
import 'role.dart';

class User extends CasdoorObject {
  User([super.json]);

  /// The unique ID (UUID) of the user. Use [getId] for the "owner/name" ID.
  String get id => getString('id');
  set id(String value) => json['id'] = value;

  String get type => getString('type');
  set type(String value) => json['type'] = value;

  String get password => getString('password');
  set password(String value) => json['password'] = value;

  String get firstName => getString('firstName');
  set firstName(String value) => json['firstName'] = value;

  String get lastName => getString('lastName');
  set lastName(String value) => json['lastName'] = value;

  String get avatar => getString('avatar');
  set avatar(String value) => json['avatar'] = value;

  String get email => getString('email');
  set email(String value) => json['email'] = value;

  bool get emailVerified => getBool('emailVerified');
  set emailVerified(bool value) => json['emailVerified'] = value;

  String get phone => getString('phone');
  set phone(String value) => json['phone'] = value;

  String get countryCode => getString('countryCode');
  set countryCode(String value) => json['countryCode'] = value;

  String get region => getString('region');
  set region(String value) => json['region'] = value;

  String get location => getString('location');
  set location(String value) => json['location'] = value;

  String get affiliation => getString('affiliation');
  set affiliation(String value) => json['affiliation'] = value;

  String get title => getString('title');
  set title(String value) => json['title'] = value;

  String get homepage => getString('homepage');
  set homepage(String value) => json['homepage'] = value;

  String get bio => getString('bio');
  set bio(String value) => json['bio'] = value;

  String get tag => getString('tag');
  set tag(String value) => json['tag'] = value;

  String get language => getString('language');
  set language(String value) => json['language'] = value;

  String get gender => getString('gender');
  set gender(String value) => json['gender'] = value;

  String get birthday => getString('birthday');
  set birthday(String value) => json['birthday'] = value;

  int get score => getInt('score');
  set score(int value) => json['score'] = value;

  int get karma => getInt('karma');
  set karma(int value) => json['karma'] = value;

  int get ranking => getInt('ranking');
  set ranking(int value) => json['ranking'] = value;

  double get balance => getDouble('balance');
  set balance(double value) => json['balance'] = value;

  bool get isOnline => getBool('isOnline');

  bool get isAdmin => getBool('isAdmin');
  set isAdmin(bool value) => json['isAdmin'] = value;

  bool get isForbidden => getBool('isForbidden');
  set isForbidden(bool value) => json['isForbidden'] = value;

  bool get isDeleted => getBool('isDeleted');
  set isDeleted(bool value) => json['isDeleted'] = value;

  String get signupApplication => getString('signupApplication');
  set signupApplication(String value) => json['signupApplication'] = value;

  String get lastSigninTime => getString('lastSigninTime');

  String get lastSigninIp => getString('lastSigninIp');

  /// The custom properties of the user.
  Map<String, String> get properties => getStringMap('properties');
  set properties(Map<String, String> value) => json['properties'] = value;

  /// The IDs ("owner/name") of the groups the user belongs to.
  List<String> get groups => getStringList('groups');
  set groups(List<String> value) => json['groups'] = value;

  List<Role> get roles => getObjectList('roles', Role.new);

  List<Permission> get permissions =>
      getObjectList('permissions', Permission.new);
}

extension CasdoorUserApi on CasdoorClient {
  /// Gets the users of all organizations.
  Future<List<User>> getGlobalUsers() =>
      getObjects('get-global-users', {}, User.new);

  Future<List<User>> getUsers() =>
      getObjects('get-users', {'owner': organizationName}, User.new);

  /// Gets the first [limit] users sorted by the DB column [sorter], such as
  /// `created_time`.
  Future<List<User>> getSortedUsers(String sorter, int limit) => getObjects(
        'get-sorted-users',
        {'owner': organizationName, 'sorter': sorter, 'limit': '$limit'},
        User.new,
      );

  /// Gets a page of users. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'alice'}`.
  Future<CasdoorPage<User>> getPaginationUsers(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-users',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        User.new,
      );

  /// Gets the number of users. If [isOnline] is set, only the online (or
  /// offline) users are counted.
  Future<int> getUserCount({bool? isOnline}) async {
    final response = await doGet('get-user-count', {
      'owner': organizationName,
      'isOnline': isOnline?.toString() ?? '',
    });
    return (response.data as num?)?.toInt() ?? 0;
  }

  /// Gets a user by name (or "owner/name" ID). Returns null if not found.
  Future<User?> getUser(String name) =>
      getObject('get-user', {'id': getId(name)}, User.new);

  /// Gets the user that the client is authenticated as. It's meant to be used
  /// with a client returned by [CasdoorClient.withAccessToken], so that the
  /// user of an access token can be retrieved:
  ///
  /// ```dart
  /// final user = await client.withAccessToken(token.accessToken).getAccount();
  /// ```
  Future<User?> getAccount() => getObject('get-account', {}, User.new);

  Future<User?> getUserByEmail(String email) => getObject(
        'get-user',
        {'owner': organizationName, 'email': email},
        User.new,
      );

  Future<User?> getUserByPhone(String phone) => getObject(
        'get-user',
        {'owner': organizationName, 'phone': phone},
        User.new,
      );

  /// Gets a user by its unique ID ([User.id]).
  Future<User?> getUserByUserId(String userId) => getObject(
        'get-user',
        {'owner': organizationName, 'userId': userId},
        User.new,
      );

  Future<bool> addUser(User user) =>
      modifyObject('add-user', user, organizationName);

  /// Updates all columns of [user]. Get the user first and change it, so that
  /// the other columns keep their values.
  Future<bool> updateUser(User user) =>
      modifyObject('update-user', user, organizationName);

  /// Updates only the [columns] of [user], such as `['displayName', 'email']`.
  Future<bool> updateUserForColumns(User user, List<String> columns) =>
      modifyObject('update-user', user, organizationName, columns: columns);

  /// Updates the user whose ID is [id] to [user], which can also rename it.
  Future<bool> updateUserById(String id, User user) =>
      modifyObject('update-user', user, organizationName, id: id);

  Future<bool> deleteUser(User user) =>
      modifyObject('delete-user', user, organizationName);

  /// Sets the password of the user [owner]/[name]. [oldPassword] can be empty
  /// when the client is authenticated as the application or an admin.
  Future<bool> setPassword(
    String owner,
    String name,
    String oldPassword,
    String newPassword,
  ) async {
    final response = await doPost('set-password', fields: {
      'userOwner': owner,
      'userName': name,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
    return response.isOk;
  }

  /// Checks whether [User.password] is the password of the user. Returns true
  /// if it is, otherwise throws a [CasdoorException] with the reason, such as
  /// a wrong password or a user that doesn't exist.
  Future<bool> checkUserPassword(User user) async {
    if (user.owner.isEmpty) {
      user.owner = organizationName;
    }

    final response = await doPost(
      'check-user-password',
      query: {'id': user.getId()},
      body: user.toJson(),
    );
    return response.isOk;
  }
}
