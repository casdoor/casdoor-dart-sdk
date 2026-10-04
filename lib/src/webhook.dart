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

class Webhook extends CasdoorObject {
  Webhook([super.json]);

  String get organization => getString('organization');
  set organization(String value) => json['organization'] = value;

  String get url => getString('url');
  set url(String value) => json['url'] = value;

  String get method => getString('method');
  set method(String value) => json['method'] = value;

  String get contentType => getString('contentType');
  set contentType(String value) => json['contentType'] = value;

  List<String> get events => getStringList('events');
  set events(List<String> value) => json['events'] = value;

  bool get isUserExtended => getBool('isUserExtended');
  set isUserExtended(bool value) => json['isUserExtended'] = value;

  bool get isEnabled => getBool('isEnabled');
  set isEnabled(bool value) => json['isEnabled'] = value;
}

extension CasdoorWebhookApi on CasdoorClient {
  Future<List<Webhook>> getWebhooks() =>
      getObjects('get-webhooks', {'owner': organizationName}, Webhook.new);

  /// Gets a page of webhooks. [query] can filter them, such as
  /// `{'field': 'name', 'value': 'foo'}`.
  Future<CasdoorPage<Webhook>> getPaginationWebhooks(
    int p,
    int pageSize, [
    Map<String, String> query = const {},
  ]) =>
      getPaginationObjects(
        'get-webhooks',
        p,
        pageSize,
        {...query, 'owner': organizationName},
        Webhook.new,
      );

  /// Gets a webhook by name (or "owner/name" ID). Returns null if not found.
  Future<Webhook?> getWebhook(String name) =>
      getObject('get-webhook', {'id': getId(name)}, Webhook.new);

  Future<bool> addWebhook(Webhook webhook) =>
      modifyObject('add-webhook', webhook, organizationName);

  Future<bool> updateWebhook(Webhook webhook) =>
      modifyObject('update-webhook', webhook, organizationName);

  Future<bool> updateWebhookForColumns(Webhook webhook, List<String> columns) =>
      modifyObject('update-webhook', webhook, organizationName,
          columns: columns);

  Future<bool> deleteWebhook(Webhook webhook) =>
      modifyObject('delete-webhook', webhook, organizationName);
}
