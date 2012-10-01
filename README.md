# CloudSpokes API

## Key Features

1. Built using [Rocket Pants!](https://github.com/filtersquad/rocket_pants) so it fully supports versioning (v1 currently).
2. JSON payloads return "pretty" field names instead of "salesforce" field names to make it more rails-like. For example, fields such as 'First_Name__c' will be returned as 'first_name'.
3. API Key support for destructive calls. Most method calls a public but one that make changes (create a challenge, post a comments, etc.) require an API Key passed via the header. Therefore, we can provide API Keys to other applications/developers (CMC) so that have full access to the platform.
4. Support for passing existing OAuth token via the header. Therefore, if no OAuth token is passed, the API will fetch a public token therfore implementing a public API functionality. Support for an exising OAuth token or Admin token being passed via the header will be passed through to Salesforce.
5. Fully tested with RSpec and VCR.

## Contributors

- [Jeff Douglas](https://github.com/jeffdonthemic) - Main developer, current maintainer.