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

class Adapter extends CasdoorObject {
  Adapter([super.json]);

  String get table => getString('table');
  set table(String value) => json['table'] = value;

  bool get useSameDb => getBool('useSameDb');
  set useSameDb(bool value) => json['useSameDb'] = value;

  String get type => getString('type');
  set type(String value) => json['type'] = value;

  String get databaseType => getString('databaseType');
  set databaseType(String value) => json['databaseType'] = value;

  String get host => getString('host');
  set host(String value) => json['host'] = value;

  int get port => getInt('port');
  set port(int value) => json['port'] = value;

  String get user => getString('user');
  set user(String value) => json['user'] = value;

  String get password => getString('password');
  set password(String value) => json['password'] = value;

  String get database => getString('database');
  set database(String value) => json['database'] = value;
}

extension CasdoorAdapterApi on CasdoorClient {
  Future<List<Adapter>> getAdapters() =>
      getObjects('get-adapters', {'owner': organizationName}, Adapter.new);

  /// Gets a page of adapters. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Adapter>> getPaginationAdapters(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-adapters',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        Adapter.new,
      );

  /// Gets a adapter by name (or "owner/name" ID). Returns null if not found.
  Future<Adapter?> getAdapter(String name) =>
      getObject('get-adapter', {'id': getId(name)}, Adapter.new);

  Future<bool> addAdapter(Adapter adapter) =>
      modifyObject('add-adapter', adapter, organizationName);

  Future<bool> updateAdapter(Adapter adapter) =>
      modifyObject('update-adapter', adapter, organizationName);

  Future<bool> updateAdapterForColumns(Adapter adapter, List<String> columns) =>
      modifyObject('update-adapter', adapter, organizationName,
          columns: columns);

  Future<bool> deleteAdapter(Adapter adapter) =>
      modifyObject('delete-adapter', adapter, organizationName);
}
