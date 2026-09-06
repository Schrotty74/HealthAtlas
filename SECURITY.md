# Security Policy

## Supported Versions

Security fixes are provided for the current stable release of HealthAtlas.

| Version | Supported |
| --- | --- |
| 1.0.x | Yes |
| Earlier versions | No |

Users should update to the latest available HealthAtlas release before reporting a security issue that may already have been fixed.

## Reporting a Vulnerability

Please do not report security vulnerabilities in a public GitHub issue.

If you believe you have found a security vulnerability in HealthAtlas, contact the maintainer privately through the contact information linked from the developer profile or portfolio. Please include enough information to reproduce and understand the issue, such as:

- the HealthAtlas version you tested
- your macOS version
- a clear description of the vulnerability and its potential impact
- steps to reproduce it
- relevant logs or screenshots, with personal health data removed

Please do not include real Apple Health exports or other sensitive personal health information in a vulnerability report.

Reports will be reviewed as soon as reasonably possible. If the issue is confirmed, a fix will be prepared and released before detailed vulnerability information is made public whenever practical.

## Scope

Security reports may include issues involving local file handling, Apple Health export parsing, generated reports, update checking, or other behavior that could affect the confidentiality, integrity, or safe operation of HealthAtlas.

HealthAtlas processes selected Apple Health exports locally and does not require an account or upload imported health data to a HealthAtlas service. The optional update check only accesses the public GitHub release list.

Thank you for helping keep HealthAtlas and its users secure.
