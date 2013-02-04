
class Church < ActiveRecord::Base
  has_many :people
  
  def to_param
    self.urn
  end
  
  def members_by_address
    address_hash = {}
    self.members.each do |mem|
      addy = mem.full_address
      if addy.present?
        address_hash[addy] ||= []
        address_hash[addy] << mem
      end
    end
    return address_hash
  end
  
  def members
    self.people.where(:member_type => ['Member', 'Non-Attending']).order("sort_name asc")
  end

  def attending_members
    self.people.where(:member_type => 'Member').order("sort_name asc")
  end

  def non_attending_members
    self.people.where(:member_type => 'Non-Attending').order("sort_name asc")
  end

  def sorted_households
    self.people.sorted_households
  end
  
  def import_directory_info_from_church_membership_online_xml(xml_filename)
    self.people.destroy_all
    xmldoc = Nokogiri::XML(File.read(xml_filename))
    cols = ['MemberID','FirstName','LastName','HouseholdID','StreetAddress','City','ZipCode','Phone','Mobile','MemberType','MemberAgeCategoryName','MaritalStatusName','GenderName','State','CountryName','Notes']
    
    imported_people = []
    
    xmldoc.xpath('//xmlns:Individuals', 'xmlns' => 'http://tempuri.org/IndividualExportDataObject.xsd').each do |indiv|
      datahash = {}
      cols.each do |c|
        datahash[c.underscore.to_sym] = indiv.css(c).text.strip
      end
      newperson = people.build(datahash)
      newperson.save
      newperson.update_photo_from_server!
      imported_people << newperson
    end
    
    self.people.update_sort_names_and_household_statuses!
    
    self.people.each do |p|
      unless p.full_address.nil?
        p.geocode
        p.save!
      end
    end
    
    imported_people
  end
  

end
