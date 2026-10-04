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

class Provider extends CasdoorObject {
  Provider([super.json]);

  String get category => getString('category');
  set category(String value) => json['category'] = value;

  String get type => getString('type');
  set type(String value) => json['type'] = value;

  String get subType => getString('subType');
  set subType(String value) => json['subType'] = value;

  String get method => getString('method');
  set method(String value) => json['method'] = value;

  String get clientId => getString('clientId');
  set clientId(String value) => json['clientId'] = value;

  String get clientSecret => getString('clientSecret');
  set clientSecret(String value) => json['clientSecret'] = value;

  String get host => getString('host');
  set host(String value) => json['host'] = value;

  int get port => getInt('port');
  set port(int value) => json['port'] = value;

  String get title => getString('title');
  set title(String value) => json['title'] = value;

  String get content => getString('content');
  set content(String value) => json['content'] = value;

  String get receiver => getString('receiver');
  set receiver(String value) => json['receiver'] = value;

  String get regionId => getString('regionId');
  set regionId(String value) => json['regionId'] = value;

  String get signName => getString('signName');
  set signName(String value) => json['signName'] = value;

  String get templateCode => getString('templateCode');
  set templateCode(String value) => json['templateCode'] = value;

  String get appId => getString('appId');
  set appId(String value) => json['appId'] = value;

  String get endpoint => getString('endpoint');
  set endpoint(String value) => json['endpoint'] = value;

  String get domain => getString('domain');
  set domain(String value) => json['domain'] = value;

  String get bucket => getString('bucket');
  set bucket(String value) => json['bucket'] = value;

  String get pathPrefix => getString('pathPrefix');
  set pathPrefix(String value) => json['pathPrefix'] = value;
}

extension CasdoorProviderApi on CasdoorClient {
  Future<List<Provider>> getProviders() =>
      getObjects('get-providers', {'owner': organizationName}, Provider.new);

  /// Gets a page of providers. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Provider>> getPaginationProviders(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-providers',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        Provider.new,
      );

  /// Gets a provider by name (or "owner/name" ID). Returns null if not found.
  Future<Provider?> getProvider(String name) =>
      getObject('get-provider', {'id': getId(name)}, Provider.new);

  Future<bool> addProvider(Provider provider) =>
      modifyObject('add-provider', provider, organizationName);

  Future<bool> updateProvider(Provider provider) =>
      modifyObject('update-provider', provider, organizationName);

  Future<bool> updateProviderForColumns(
          Provider provider, List<String> columns) =>
      modifyObject('update-provider', provider, organizationName,
          columns: columns);

  Future<bool> deleteProvider(Provider provider) =>
      modifyObject('delete-provider', provider, organizationName);
}
