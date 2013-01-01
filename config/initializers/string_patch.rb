class String
	def to_bool
		return true if self=="true"
		return false if self=="false"
		return nil
	end
end