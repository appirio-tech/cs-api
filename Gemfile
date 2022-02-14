source 'https://rubygems.org'
ruby '1.9.2'

gem 'rails', '5.2.6.2'

gem 'restforce', '1.1.0'
gem 'forcifier', git: 'git://github.com/jeffdonthemic/forcifier.git'
gem 'rocket_pants', '~> 1.0'
gem 'httparty'
gem 'pg'
gem 'unicorn'
gem 'dalli'
gem 'savon', '1.2.0'
gem 'ratchetio', '~> 0.6.0'
gem 'newrelic_rpm'
gem 'rack-timeout', '0.1.0beta2'

group :development, :test do
	gem 'sqlite3'
	gem 'rspec-rails', '~> 2.12', '>= 2.12.1'
	gem 'vcr'
	gem 'fakeweb'
	gem 'sextant', '>= 0.1.3'
end

group :test do
  gem 'rake'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request', '0.2.1' # see https://github.com/dejan/rails_panel
end