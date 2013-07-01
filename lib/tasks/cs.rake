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

desc "Runs the /misc-util REST service"
task :run_misc_util => :environment do
  access_token = '00DU0000000H5Ip!AQQAQM2rAq._VRll7dBIidskdoQtCqjx3y3N.Vh6HtJpc_s_21OHRtWT_CUG0CYBGdYebg4anI_44KOa_Z3W5nbEfkFtMruU'
  counter = 0
  while counter < 1151
    puts "#{counter} -- #{Utility.run(access_token).to_s}"
    counter += 1
  end
end