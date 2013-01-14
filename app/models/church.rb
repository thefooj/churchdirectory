require 'iconv'
require 'roo'

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
    self.people.where(:member_type => 'Member').order("sort_name asc")
  end

  def non_attending_members
    self.people.where(:member_type => 'Non-Attending').order("sort_name asc")
  end

  def sorted_households
    self.people.sorted_households
  end
  
  def import_directory_info_from_church_membership_online(excel_filename)
    ss = Excel.new(excel_filename)
    ss.default_sheet = ss.sheets.first
    
    self.people.destroy_all
    
    people_columns = Person.column_names
    
    imported_people = []
    
    columns = ss.first_column.upto(ss.last_column).to_a.map {|col| ss.cell(ss.first_row, col)} 
    (ss.first_row + 1).upto(ss.last_row) do |rownum|
      datahash = {}
      columns.each_with_index do |col,idx|
        symbolized_col = col.underscore.to_sym
        if people_columns.include?(symbolized_col.to_s)
          val = ss.cell(rownum,idx+1) 
          if val =~ /[0-9]{1,2}\/\d{1,2}\/\d{4}/
            val = Date.strptime(val, '%m/%d/%Y')
          end
          datahash[symbolized_col] = val
        end
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
        p.save
        sleep(2)
      end
    end
    
    imported_people
  end
end
