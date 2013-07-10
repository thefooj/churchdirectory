
class Church < ActiveRecord::Base
  has_many :people
  has_many :csv_uploads
  has_many :church_users
  has_many :users, :through => :church_users
  
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
    self.people.sorted_households(self.id)
  end
  
  def clear_prior_people!
    self.people.destroy_all
  end
  
  def update_all_sort_names_and_household_statuses!
    Person.update_sort_names_and_household_statuses!(self.id)
  end

  def import_directory_info_from_church_membership_online_csv(csv_upload, rows_at_a_time=10)
    raise StandardError, "No Upload Provided" if !csv_upload.present? || !csv_upload.is_a?(CsvUpload)
    
    imported_people = []
    
    csv_upload.next_batch_of_incomplete_rows(rows_at_a_time).each do |csvrow|
      the_csv = csv_upload.header.chomp + "\n" + csvrow.rowtext.chomp
      CSV.parse(the_csv, :headers => true) do |row|
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
      
      csvrow.mark_complete!
    end
            
    imported_people.each do |p|
      unless p.full_address.nil?
        p.geocode
        p.save!
      end
    end
    
    csv_upload.mark_complete_if_done!
    
    imported_people
  end
  
  def add_user_by_email(email)
    u = User.find_by_email(email)
    unless u.present?
      raise StandardError, "Cannot find a user with email #{email}"
    end
    if self.users.where(:email => email).count > 0
      raise StandardError, "Already have #{email} as a user of this church"
    end
    
    if u.present?
      self.church_users.build(:user_id => u.id).save!
    end
  end

  def includes_user?(user)
    user.present? && user.is_a?(User) && self.users.where(["users.id = ?", user.id]).count > 0
  end

end
