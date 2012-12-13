class Hash
  def rename_key(old_key, new_key)
    return Hash.rename_key(self.dup, old_key, new_key)
  end
  
  def rename_key!(old_key, new_key)
    return Hash.rename_key(self, old_key, new_key)
  end
  
  def all_values_empty?
    self.each_value do |v|
      return false if v and v != ""
    end
    
    return true
  end
  
  private
    def self.rename_key(hsh, old_key, new_key)
      hsh[new_key.to_s] = hsh.delete(old_key.to_s)
      return hsh
    end
end