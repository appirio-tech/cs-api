class Forcifier

	STANDARD_FIELDS = %w(id name)

  #
  # Adds "__c" to all non-standard salesforce.com fields
  # * *Args*    :
  #   - fields -> comma separated list of fields "id,name,wins"
  # * *Returns* :
  #   - comma separated list of fields "id,name,wins__c"
  # * *Raises* :
  #   - ++ ->
  #  
	def self.enforce_fields(fields)
		forced_fields = []
		fields.downcase.split(',').each do |f|
			if STANDARD_FIELDS.include?(f)
				forced_fields << f
			else
				forced_fields << "#{f}__c"
			end
		end
		forced_fields.join(",")
	end

  #
  # Removes "__c" from all fields fields
  # * *Args*    :
  #   - fields -> comma separated list of fields "id,name,wins__c"
  # * *Returns* :
  #   - comma separated list of fields "id,name,wins"
  # * *Raises* :
  #   - ++ ->
  #  
	def self.deforce_fields(fields)
		deforced_fields = []
		fields.downcase.split(',').each do |f|
			deforced_fields << f.gsub('__c','')
		end
		deforced_fields.join(",")		
	end

end