
require 'open-uri'
require 'digest/md5'

class Person < ActiveRecord::Base
  belongs_to :church
  geocoded_by :full_address

  MD5_DIGEST_OF_NO_IMAGE_FILE = [
    "a8ff3c35f2ca9535980cea9caf5c9df8",
    "52ad514186f9c1ca36a9f4c01066f705",
    "5662d2835c2a8052cb8859540044dac0",
    "50e9848299e06afc03f015229be7bfe0",
    "08e8346f9e0447d6ca631ba843c4ab77"
  ]
  
  has_attached_file :photo

  def self.street_abbreviations
    @street_abbrev ||= {
      'Avenue' => 'Ave',
      'Boulevard' => 'Blvd',
      'Court' => 'Ct',
      'Drive' => 'Dr',
      'Expressway' => 'Expy',
      'Freeway' => 'Fwy',
      'Highway' => 'Hwy',
      'Lane' => 'Ln',
      'Parkway' => 'Pkwy',
      'Place' => 'Pl',
      'Road' => 'Rd',
      'Square' => 'Sq',
      'Street' => 'St',
      'Turnpike' => 'Tpke',
    }
  end

  def self.state_abbreviations
    @state_abbrev ||= states = {
      "Alabama" => "AL",
      "Alaska" => "AK",
      "Arizona" => "AZ",
      "Arkansas" => "AR",
      "California" => "CA",
      "Colorado" => "CO",
      "Connecticut" => "CT",
      "Delaware" => "DE",
      "District of Columbia" => "DC",
      "Washington D.C." => "DC",
      "Florida" => "FL",
      "Georgia" => "GA",
      "Hawaii" => "HI",
      "Idaho" => "ID",
      "Illinois" => "IL",
      "Indiana" => "IN",
      "Iowa" => "IA",
      "Kansas" => "KS",
      "Kentucky" => "KY",
      "Louisiana" => "LA",
      "Maine" => "ME",
      "Maryland" => "MD",
      "Massachusetts" => "MA",
      "Michigan" => "MI",
      "Minnesota" => "MN",
      "Mississippi" => "MS",
      "Missouri" => "MO",
      "Montana" => "MT",
      "Nebraska" => "NE",
      "Nevada" => "NV",
      "New Hampshire" => "NH",
      "New Jersey" => "NJ",
      "New Mexico" => "NM",
      "New York" => "NY",
      "North Carolina" => "NC",
      "North Dakota" => "ND",
      "Ohio" => "OH",
      "Oklahoma" => "OK",
      "Oregon" => "OR",
      "Pennsylvania" => "PA",
      "Rhode Island" => "RI",
      "South Carolina" => "SC",
      "South Dakota" => "SD",
      "Tennessee" => "TN",
      "Texas" => "TX",
      "Utah" => "UT",
      "Vermont" => "VT",
      "Virginia" => "VA",
      "Washington" => "WA",
      "West Virginia" => "WV",
      "Wisconsin" => "WI",
      "Wyoming" => "WY"
    }
  end

  def self.geocode_all
    self.not_geocoded.order("sort_name asc").all.each do |p|
      unless p.full_address.blank?
        puts "Geocoding #{p.sort_name} - #{p.full_address}"
        p.geocode
        p.save!
      end
    end
  end
  
  def full_name
    extracted_suffix = ""
    
    if self.first_name =~ /(\, .+$)/
      extracted_suffix = $1
    end
    "#{self.first_name.gsub(/\, .+$/,'')} #{self.last_name}#{extracted_suffix}"
  end

  def full_address
    if street_address.present? && street_address != 'Unknown' && street_address !~ /P.O. Box/ && city.present? && state.present? && zip_code.present?
      "#{street_address}, #{city}, #{state}, #{zip_code}"
    else
      nil
    end
  end
  
  def state_abbrev
    return "" if self.state.blank?
    self.class.state_abbreviations[self.state]
  end
  
  def street_address_short
    thestreet = self.street_address
    self.class.street_abbreviations.each_pair do |str, abbrev|
      if thestreet =~ / #{str}$/i
        thestreet = thestreet.gsub(/ #{str}$/, " #{abbrev}")
      end
    end
    return thestreet
  end
  
  def zip_code_short
    return "" if self.zip_code.blank?
    self.zip_code.gsub(/\-\d+$/,'')
  end


  def update_photo_from_server!
    
    
    the_url = "https://www.churchmembershiponline.com/IndividualImageHandler.ashx?MemberID=#{self.member_id}"

    tmp_file_name = "#{Rails.root}/tmp/tmpfile#{Digest::MD5.hexdigest(the_url.to_s)}.jpg"
    tmp_file = open(tmp_file_name, "wb") {|f| f.write(open(the_url).read)}
    file_md5 = Digest::MD5.file(tmp_file_name).hexdigest
    
    if !MD5_DIGEST_OF_NO_IMAGE_FILE.include?(file_md5)
      the_file = File.open(tmp_file_name, "rb")
      self.photo = the_file
      the_file.close
    else
      self.photo = nil
    end
    self.save!    
    File.delete(tmp_file_name)    
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
    self.where(:household_id => household_identifier, :member_type => 'Dependent').order("date_of_birth asc")
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
