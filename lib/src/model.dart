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

class Model extends CasdoorObject {
  Model([super.json]);

  String get description => getString('description');
  set description(String value) => json['description'] = value;

  String get modelText => getString('modelText');
  set modelText(String value) => json['modelText'] = value;
}

extension CasdoorModelApi on CasdoorClient {
  Future<List<Model>> getModels() =>
      getObjects('get-models', {'owner': organizationName}, Model.new);

  /// Gets a page of models. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Model>> getPaginationModels(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-models',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        Model.new,
      );

  /// Gets a model by name (or "owner/name" ID). Returns null if not found.
  Future<Model?> getModel(String name) =>
      getObject('get-model', {'id': getId(name)}, Model.new);

  Future<bool> addModel(Model model) =>
      modifyObject('add-model', model, organizationName);

  Future<bool> updateModel(Model model) =>
      modifyObject('update-model', model, organizationName);

  Future<bool> updateModelForColumns(Model model, List<String> columns) =>
      modifyObject('update-model', model, organizationName, columns: columns);

  Future<bool> deleteModel(Model model) =>
      modifyObject('delete-model', model, organizationName);
}
