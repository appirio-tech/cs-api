# CloudSpokes API [![Build Status](https://travis-ci.org/cloudspokes/cs-api.png?branch=master)](https://travis-ci.org/cloudspokes/cs-api) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/cloudspokes/cs-api)

A full list of the API controllers and models is available [here](https://docs.google.com/a/appirio.com/spreadsheet/ccc?key=0AibvDu-BSYDZdDdWTHFKcjVwVDlKS3FieE1wZHhCbVE#gid=0)

## Key Features

1. Built using [Rocket Pants!](https://github.com/filtersquad/rocket_pants) so it fully supports versioning (v1 currently).
2. JSON payloads return "pretty" field names instead of "salesforce" field names to make it more rails-like. For example, fields such as 'First_Name__c' will be returned as 'first_name'. Uses the [Forcifier gem](https://github.com/jeffdonthemic/forcifier).
3. API Key support for destructive calls. Most method calls are public but ones that make changes (create a challenge, post a comments, etc.) require an API Key passed via the header. Therefore, we can provide API Keys to other applications/developers (CMC) so that they have full access to the platform.
4. Support for passing existing OAuth token via the header. Therefore, if no OAuth token is passed, the API will fetch a public token therefore implementing a public API functionality. Support for an exising OAuth token or Admin token being passed via the header will be passed through to Salesforce.
5. Fully tested with RSpec and VCR.

## Production Environment

The endpoint for the production environment is [https://api.cloudspokes.com](https://api.cloudspokes.com). There is a [small exmaple page](https://api.cloudspokes.com/examples.html) for some standard calls that you might want to take a look at. You will need an API Key to make any non-public calls.

## Sandbox Environment

The endpoint for the sandbox environment is [http://api-sandbox.cloudspokes.com](http://api-sandbox.cloudspokes.com). There is a [small exmaple page](http://api-sandbox.cloudspokes.com/examples.html) for some standard calls that you might want to take a look at. You will need an API Key to make any non-public calls so please send a request to support@cloudspokes.com with the subject "Sandbox API Key Request".

## API Calls

A large portion of the API calls are public. For example, the following returns a JSON collection of open challenges:

	curl https://api.cloudspokes.com/v1/challenges

If you are making a call for a specific user (i.e., "give me all of the open challenges that user xyz has access to"), then you need to pass the user's access token (POST their credentials to /accounts/authenticate to obtain their access token) as part of the header in your call:

	curl https://api.cloudspokes.com/v1/challenges -H 'oauth_token: THE-ACCESS-TOKEN'

Some API calls (updating a member's payment info, obtaining outstanding payments owed, changing a member's password, etc) are private and require an API Key for authorization. These keys are not typically given out for our production environment but can be obtained for testing and development for our sandbox environment (see above for requesting an API Key). 

	curl https://api.cloudspokes.com/v1/members/jeffdonthemic/referrals -H 'Authorization: Token token="THE-API-KEY"'

## Road Map

1. Implement better pagination with Header Metadata via RocketPants

## Contributors

- [Jeff Douglas](https://github.com/jeffdonthemic) - Main developer, current maintainer.