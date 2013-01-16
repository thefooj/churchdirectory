class GeocodeCache < ActiveRecord::Base
  def self.[](key)
    self.where(:key => key).first.try(:value)
  end
  
  def self.[]=(key,value)
    self.where(:key => key).first_or_create(:value => value)
    value
  end
  
  def self.keys
    self.uniq.pluck(:key)
  end
  
  def self.del(key)
    self.delete_all(["`key` = ?", key])
  end
end