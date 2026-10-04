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

class Cert extends CasdoorObject {
  Cert([super.json]);

  String get scope => getString('scope');
  set scope(String value) => json['scope'] = value;

  String get type => getString('type');
  set type(String value) => json['type'] = value;

  String get cryptoAlgorithm => getString('cryptoAlgorithm');
  set cryptoAlgorithm(String value) => json['cryptoAlgorithm'] = value;

  int get bitSize => getInt('bitSize');
  set bitSize(int value) => json['bitSize'] = value;

  int get expireInYears => getInt('expireInYears');
  set expireInYears(int value) => json['expireInYears'] = value;

  String get certificate => getString('certificate');
  set certificate(String value) => json['certificate'] = value;

  String get privateKey => getString('privateKey');
  set privateKey(String value) => json['privateKey'] = value;
}

extension CasdoorCertApi on CasdoorClient {
  Future<List<Cert>> getCerts() =>
      getObjects('get-certs', {'owner': organizationName}, Cert.new);

  /// Gets a page of certs. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Cert>> getPaginationCerts(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-certs',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        Cert.new,
      );

  /// Gets a cert by name (or "owner/name" ID). Returns null if not found.
  Future<Cert?> getCert(String name) =>
      getObject('get-cert', {'id': getId(name)}, Cert.new);

  Future<bool> addCert(Cert cert) =>
      modifyObject('add-cert', cert, organizationName);

  Future<bool> updateCert(Cert cert) =>
      modifyObject('update-cert', cert, organizationName);

  Future<bool> updateCertForColumns(Cert cert, List<String> columns) =>
      modifyObject('update-cert', cert, organizationName, columns: columns);

  Future<bool> deleteCert(Cert cert) =>
      modifyObject('delete-cert', cert, organizationName);
}
