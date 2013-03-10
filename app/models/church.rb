
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
  
  def import_directory_info_from_church_membership_online_csv(csv_filename)
    
    # {"IndividualId"=>"0571b3d5-fbf7-4fcf-88e7-a2d818e2a31f", "HouseholdId"=>"d221cdac-58e1-4c8c-93ab-93265f2e4849", "First Name"=>"Nancy", "Last Name"=>"Alicea", "Street Address"=>"3401 Sterling Avenue", "City"=>"Alexandria", "State / Province"=>"Virginia", "Postal Code"=>"22304", "Country"=>"United States", "Phone"=>"703-751-0597", "Mobile"=>nil, "Email"=>nil, "Marital Status"=>"Married", "Member Type"=>"Member", "Age Category"=>"Adult", "Gender"=>"Female", "Envelope Number"=>nil, "Date of Birth"=>"2/24/0001", "Anniversary Date"=>"3/9/0001", "Membership Date"=>nil, "Allergies and Special Instructions"=>nil, "Responsible Party Name and Relationship"=>nil, "Responsible Party Contact"=>nil, "Notes"=>nil, "SignificantRelationship04"=>nil, "SignificantRelationship06"=>nil, "Birthdate"=>nil, "Children"=>nil, "SignificantRelationship03"=>nil, "SignificantRelationship02"=>nil, "LeadershipRole"=>nil, "SignificantRelationship05"=>nil, "SignificantRelationship08"=>nil, "CommunityGroup"=>nil, "SignificantRelationship07"=>nil, "SignificantRelationship01"=>nil, "SignificantRelationship10"=>nil, "SignificantRelationship09"=>nil}
    self.people.destroy_all
    imported_people = []
    CSV.foreach(csv_filename, headers: true) do |row|
      rowhash = row.to_hash
      newperson = people.build(
        :member_id => rowhash['IndividualId'],
        :household_id => rowhash['HouseholdId'],
        :first_name => rowhash['First Name'],
        :last_name => rowhash['Last Name'],
        :street_address => rowhash['Street Address'],
        :city => rowhash['City'],
        :state => rowhash['State / Province'],
        :zip_code => rowhash['Postal Code'],
        :phone => rowhash['Phone'],
        :mobile => rowhash['Mobile'],
        :email_address => rowhash['Email'],
        :country_name => rowhash['Country'],
        :member_type => rowhash['Member Type'],
        :notes => rowhash['Notes'],
        :gender_name => rowhash['Gender'],
        :member_age_category_name => rowhash['Age Category'],
        :marital_status_name => rowhash["Marital Status"])
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
