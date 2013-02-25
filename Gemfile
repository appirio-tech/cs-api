source 'https://rubygems.org'

gem 'rails', '3.2.11'

gem 'restforce'
gem 'forcifier', git: 'git://github.com/jeffdonthemic/forcifier.git'
gem 'rocket_pants', '~> 1.0'
gem 'httparty'
gem 'pg'
gem 'thin'
gem 'dalli'
gem 'debugger'
gem 'airbrake'
gem 'simplecov', '>= 0.4.0', :require => false, :group => :test
gem 'savon', '1.2.0'
gem 'bunny'
gem 'ratchetio', '~> 0.6.0'
gem 'newrelic_rpm'

group :production do
  gem 'pg'
end

group :development, :test do
	gem 'sqlite3'
	gem 'rspec-rails', '~> 2.6'
	gem 'vcr'
	gem 'fakeweb'
	gem 'sextant'
end

group :test do
  gem 'rake'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request', '0.2.1' # see https://github.com/dejan/rails_panel
end