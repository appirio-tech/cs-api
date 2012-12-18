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

  #non-destructive version
  def remove_key(*keys)
    self.dup.remove!(*keys)
  end  

  def remove_key!(*keys)
    keys.each{|key| self.delete(key) }
    self
  end
  
  private
    def self.rename_key(hsh, old_key, new_key)
      hsh[new_key.to_s] = hsh.delete(old_key.to_s)
      return hsh
    end
end