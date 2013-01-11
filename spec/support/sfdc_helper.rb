class SfdcHelper

	def self.public_access_token
		puts "[SETUP] fetching new access token....."
	  client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
	    :password       => ENV['SFDC_PUBLIC_PASSWORD'],
	    :client_id      => ENV['DATABASEDOTCOM_CLIENT_ID'],
	    :client_secret  => ENV['DATABASEDOTCOM_CLIENT_SECRET'],
	    :host           => ENV['DATABASEDOTCOM_HOST']
	  client.authenticate!.access_token
	end

	def self.admin_access_token
		puts "[SETUP] fetching new admin access token....."
	  client = Restforce.new :username => ENV['SFDC_ADMIN_USERNAME'],
	    :password       => ENV['SFDC_ADMIN_PASSWORD'],
	    :client_id      => ENV['DATABASEDOTCOM_CLIENT_ID'],
	    :client_secret  => ENV['DATABASEDOTCOM_CLIENT_SECRET'],
	    :host           => ENV['DATABASEDOTCOM_HOST']
	  client.authenticate!.access_token
	end

end