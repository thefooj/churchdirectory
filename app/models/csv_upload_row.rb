
class CsvUploadRow < ActiveRecord::Base
  belongs_to :csv_upload
  
  def complete?
    self.status == 'Complete'
  end
  
  def mark_complete!
    update_attributes!(:status => 'Complete')
  end
end