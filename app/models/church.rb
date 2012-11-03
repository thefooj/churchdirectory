require 'iconv'
require 'roo'

class Church < ActiveRecord::Base
  has_many :people
  
  def to_param
    self.urn
  end
  
  def members
    self.people.where(:member_type => 'Member').order("last_name asc, first_name asc")
  end

  def non_attending_members
    self.people.where(:member_type => 'Non-Attending').order("last_name asc, first_name asc")
  end

  def sorted_households
    self.people.sorted_households
  end
  
  def import_directory_info_from_church_membership_online(excel_filename)
    ss = Excel.new(excel_filename)
    ss.default_sheet = ss.sheets.first
    
    self.people.delete_all
    
    people_columns = Person.column_names
    
    columns = ss.first_column.upto(ss.last_column).to_a.map {|col| ss.cell(ss.first_row, col)} 
    (ss.first_row + 1).upto(ss.last_row) do |rownum|
      datahash = {}
      columns.each_with_index do |col,idx|
        symbolized_col = col.underscore.to_sym
        if people_columns.include?(symbolized_col.to_s)
          datahash[symbolized_col] = ss.cell(rownum,idx+1) 
        end
      end
      self.people.build(datahash).save!
    end
  end
end
