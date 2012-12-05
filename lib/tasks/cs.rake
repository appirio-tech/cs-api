desc "Returns a salesforce.com access token for the current environment for the public user"
task :get_public_access_token => :environment do
	# log in for an access token
	config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
	client = Databasedotcom::Client.new(config)
	access_token = client.authenticate :username => ENV['SFDC_PUBLIC_USERNAME'], 
		:password => ENV['SFDC_PUBLIC_PASSWORD']  
	puts "Public access token for #{ENV['DATABASEDOTCOM_HOST']}: #{access_token}"
end

desc "Returns a salesforce.com access token for the current environment for the admin user"
task :get_admin_access_token => :environment do
	# log in for an access token
	config = YAML.load_file(File.join(::Rails.root, 'config', 'databasedotcom.yml'))
	client = Databasedotcom::Client.new(config)
	access_token = client.authenticate :username => ENV['SFDC_ADMIN_USERNAME'], 
		:password => ENV['SFDC_ADMIN_PASSWORD']  
	puts "Admin access token for #{ENV['DATABASEDOTCOM_HOST']}: #{access_token}"
end

desc "Calculate success probability for open challenges"
task :calculate_success => :environment do

	client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
	  :password       => ENV['SFDC_PUBLIC_PASSWORD'],
	  :client_id      => ENV['DATABASEDOTCOM_CLIENT_ID'],
	  :client_secret  => ENV['DATABASEDOTCOM_CLIENT_SECRET']	
	access_token = client.authenticate!.access_token

	# get all of the open challenges
	Challenge.all(access_token, 'true', nil, 'name').each do |c|
		start_date = Date.parse(c['start_date'])
		end_date = Date.parse(c['end_date'])
		total_number_of_days = (end_date - start_date).to_i
		puts "===== #{c['name']} --- {#total_number_of_days}"
	end
	

end