source 'https://rubygems.org'

gem 'rails', '3.2.6'

gem 'databasedotcom'
gem 'databasedotcom-rails'
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
gem 'savon'
gem 'bunny'

group :development, :test do
	gem 'sqlite3'
	gem 'rspec-rails', '~> 2.6'
	gem 'vcr'
	gem 'fakeweb'
end

group :test do
  gem 'rake'
end

group :production do
  gem 'pg'
end