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

/// The JWT signing algorithms Casdoor can sign tokens with, see the cert's
/// "Crypto algorithm" in Casdoor.
const defaultJwtAlgorithms = <String>[
  'RS256',
  'RS384',
  'RS512',
  'PS256',
  'PS384',
  'PS512',
  'ES256',
  'ES384',
  'ES512',
];

/// The configuration of a [CasdoorClient], taken from the Casdoor application
/// that the backend signs users in with.
class CasdoorConfig {
  const CasdoorConfig({
    required this.endpoint,
    required this.clientId,
    required this.clientSecret,
    required this.certificate,
    required this.organizationName,
    this.applicationName = '',
    this.jwtAlgorithms = defaultJwtAlgorithms,
  });

  /// The Casdoor server URL, such as `https://door.casdoor.com`.
  final String endpoint;

  /// The client ID of the Casdoor application.
  final String clientId;

  /// The client secret of the Casdoor application.
  final String clientSecret;

  /// The x509 certificate (or public key) of the application's cert, in PEM
  /// format. It's used to verify the JWT tokens issued by Casdoor.
  final String certificate;

  /// The name of the Casdoor organization.
  final String organizationName;

  /// The name of the Casdoor application.
  final String applicationName;

  /// The JWT signing algorithms accepted by `parseJwtToken()`.
  final List<String> jwtAlgorithms;
}
