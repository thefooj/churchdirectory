class Person < ActiveRecord::Base
  belongs_to :church
  
  def full_name
    extracted_suffix = ""
    
    if self.first_name =~ /(\, .+$)/
      extracted_suffix = $1
    end
    "#{self.first_name.gsub(/\, .+$/,'')} #{self.last_name}#{extracted_suffix}"
  end

  def self.update_sort_names_and_household_statuses!
    sorted_households.each do |hh|
      hh[:head_of_household].update_attributes!(:is_head_of_household => true)
      if hh[:spouse_of_household].present?
        hh[:spouse_of_household].update_attributes!(:is_spouse_of_head_of_household => true)
      end
    end
    all.each {|p| p.update_attributes!(:sort_name => p.compute_sort_name)}
  end

  def compute_sort_name
    sort_name = "#{self.last_name}, #{self.first_name}"
    if self.is_part_of_household? 
      if self.is_head_of_household?
        sort_name = "#{self.last_name}, #{self.first_name} [#{self.household_id}]"
      elsif self.is_spouse_of_head_of_household?
        sort_name = "#{Person.head_of_household(self.household_id).compute_sort_name} 000 #{self.first_name}"
      else
        sort_name = "#{Person.head_of_household(self.household_id).compute_sort_name} #{self.first_name}"
      end
    end
    sort_name
  end
  
  def is_part_of_household?
    self.household_id.present?
  end

  def self.head_of_household(household_identifier)
    # the order for finding is:
    #    Adult Married Male
    #    Adult Married Female (husband is not HoH in our system - non-believing spouse, etc)
    #    Adult Single Male w/ kids (divorced with kids, widower, single dad)
    #    Adult Single Female w/ kids (divorced with kids, widow, single mom)
    options = [
      self.where("member_type <> 'Dependent'").where(:household_id => household_identifier, :member_age_category_name => 'Adult', :gender_name => 'Male', :marital_status_name => 'Married').first,
      self.where("member_type <> 'Dependent'").where(:household_id => household_identifier, :member_age_category_name => 'Adult', :gender_name => 'Female', :marital_status_name => 'Married').first,
      self.where("member_type <> 'Dependent'").where(:household_id => household_identifier, :member_age_category_name => 'Adult', :gender_name => 'Male', :marital_status_name => 'Single').first,
      self.where("member_type <> 'Dependent'").where(:household_id => household_identifier, :member_age_category_name => 'Adult', :gender_name => 'Female', :marital_status_name => 'Single').first,
    ]
    options.compact.first
  end
  
  def self.spouse_of_household(household_identifier)
    head_of_house = self.head_of_household(household_identifier)
    likely_wife = self.where("id <> ?", head_of_house.id).where("member_type <> 'Dependent'").where(:household_id => household_identifier, :member_age_category_name => 'Adult', :gender_name => 'Female', :marital_status_name => 'Married').first
    return likely_wife
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
          full_name = "#{head_oh.last_name}, #{head_oh.first_name} and #{spouse_oh.first_name}"
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
