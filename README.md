# CloudSpokes API

A full list of the API controllers and models is available [here](https://docs.google.com/a/appirio.com/spreadsheet/ccc?key=0AibvDu-BSYDZdDdWTHFKcjVwVDlKS3FieE1wZHhCbVE#gid=0)

You can see the code metrics at [cloudspokes/cs-api](https://codeclimate.com/github/cloudspokes/cs-api)

## Key Features

1. Built using [Rocket Pants!](https://github.com/filtersquad/rocket_pants) so it fully supports versioning (v1 currently).
2. JSON payloads return "pretty" field names instead of "salesforce" field names to make it more rails-like. For example, fields such as 'First_Name__c' will be returned as 'first_name'. Uses the [Forcifier gem](https://github.com/jeffdonthemic/forcifier).
3. API Key support for destructive calls. Most method calls are public but ones that make changes (create a challenge, post a comments, etc.) require an API Key passed via the header. Therefore, we can provide API Keys to other applications/developers (CMC) so that they have full access to the platform.
4. Support for passing existing OAuth token via the header. Therefore, if no OAuth token is passed, the API will fetch a public token therefore implementing a public API functionality. Support for an exising OAuth token or Admin token being passed via the header will be passed through to Salesforce.
5. Fully tested with RSpec and VCR.

## Road Map

1. Add JSONP support via RocketPants
2. Implement better pagination with Header Metadata via RocketPants

## Contributors

- [Jeff Douglas](https://github.com/jeffdonthemic) - Main developer, current maintainer.