class ApiKey < ActiveRecord::Base
	before_create :generate_access_key

	private

	def generate_access_key
	  begin
	    self.access_key = SecureRandom.hex
	  end while self.class.exists?(access_key: access_key)
	end

end
