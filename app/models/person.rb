class Person < ActiveRecord::Base
  belongs_to :church
  
  
  def is_part_of_household?
    self.household_id.present?
  end
  
  def is_head_of_household?
    self.is_part_of_household? && self.gender_name == 'Male' && self.marital_status_name == 'Married'
  end

  def self.head_of_household(household_identifier)
    self.where(:household_id => household_identifier, :member_age_category_name => 'Adult').order("gender_name desc, marital_status_name desc").first
  end
  
  def self.spouse_of_household(household_identifier)
    hoh = self.head_of_household(household_identifier)
    self.where(["household_id = ? and member_age_category_name = ? and marital_status_name = ? and id <> ?", household_identifier, 'Adult', 'Married', hoh.id]).first
  end
  
  def self.household_dependents(household_identifier)
    self.where(:household_id => household_identifier, :member_type => 'Dependent').order("first_name asc")
  end
  
  def self.distinct_household_identifiers
    self.where("household_id is not null").uniq.pluck(:household_id)
  end
  
  def self.sorted_households
    hhids = self.distinct_household_identifiers
    households = []
    hhids.each do |hhid|
      head_oh = head_of_household(hhid)
      spouse_oh = spouse_of_household(hhid)
      full_name = ""
      if spouse_oh.present?
        if head_oh.last_name == spouse_oh.last_name
          full_name = "#{head_oh.last_name}, #{head_oh.first_name} and #{spouse_oh.last_name}"
        else
          full_name = "#{head_oh.last_name}, #{head_oh.first_name} and #{spouse_oh.last_name}, #{spouse_oh.first_name}"
        end
      else
        full_name = "#{head_oh.last_name}, #{head_oh.first_name}"
      end
      household = {
        :household_id => hhid,
        :full_name => full_name,
        :head_of_household => head_oh,
        :spouse_of_household => spouse_oh,
        :children => household_dependents(hhid),
      }
      households << household
    end
    
    households.sort {|a,b| a[:full_name] <=> b[:full_name]}
  end
end
