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

/// The base class of all Casdoor objects (users, roles, permissions, ...).
///
/// An object keeps the whole JSON returned by Casdoor in [json], and the typed
/// getters and setters of the subclasses read and write that map. So fields
/// that this SDK doesn't know about (for example ones added by a newer Casdoor
/// version) are kept as they are, and are sent back unchanged by an update.
/// Use `object['field']` to access such a field.
class CasdoorObject {
  CasdoorObject([Map<String, dynamic>? json]) : json = json ?? {};

  final Map<String, dynamic> json;

  String get owner => getString('owner');
  set owner(String value) => json['owner'] = value;

  String get name => getString('name');
  set name(String value) => json['name'] = value;

  String get createdTime => getString('createdTime');
  set createdTime(String value) => json['createdTime'] = value;

  String get displayName => getString('displayName');
  set displayName(String value) => json['displayName'] = value;

  /// The Casdoor ID of the object: "owner/name".
  String getId() => '$owner/$name';

  dynamic operator [](String key) => json[key];
  void operator []=(String key, dynamic value) => json[key] = value;

  Map<String, dynamic> toJson() => json;

  String getString(String key) => json[key]?.toString() ?? '';

  bool getBool(String key) => json[key] == true;

  int getInt(String key) => (json[key] as num?)?.toInt() ?? 0;

  double getDouble(String key) => (json[key] as num?)?.toDouble() ?? 0;

  List<String> getStringList(String key) =>
      (json[key] as List?)?.map((e) => e.toString()).toList() ?? [];

  Map<String, String> getStringMap(String key) =>
      (json[key] as Map?)
          ?.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')) ??
      {};

  List<T> getObjectList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) =>
      (json[key] as List?)
          ?.whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
      [];

  @override
  String toString() => '$runtimeType(${getId()})';
}
