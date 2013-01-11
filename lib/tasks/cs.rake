desc "Returns a salesforce.com access token for the current environment for the public user"
task :get_public_access_token => :environment do
	client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
	  :password       => ENV['SFDC_PUBLIC_PASSWORD'],
	  :client_id      => ENV['DATABASEDOTCOM_CLIENT_ID'],
	  :client_secret  => ENV['DATABASEDOTCOM_CLIENT_SECRET'],
	  :host           => ENV['DATABASEDOTCOM_HOST']
	access_token = client.authenticate!.access_token 
	puts "Public access token for #{ENV['DATABASEDOTCOM_HOST']}: #{access_token}"
end

desc "Returns a salesforce.com access token for the current environment for the admin user"
task :get_admin_access_token => :environment do
	client = Restforce.new :username => ENV['SFDC_ADMIN_USERNAME'],
	  :password       => ENV['SFDC_ADMIN_PASSWORD'],
	  :client_id      => ENV['DATABASEDOTCOM_CLIENT_ID'],
	  :client_secret  => ENV['DATABASEDOTCOM_CLIENT_SECRET'],
	  :host           => ENV['DATABASEDOTCOM_HOST']
	access_token = client.authenticate!.access_token 
	puts "Admin access token for #{ENV['DATABASEDOTCOM_HOST']}: #{access_token}"
end

desc "Calculate success probability for open, public challenges"
task :run_health_check => :environment do
	Challenge.run_health_check
end