
class CsvUpload < ActiveRecord::Base
  belongs_to :church
  has_many :csv_upload_rows
  
  
  def complete?
    self.status == 'Complete'
  end
  
  def mark_complete!
    update_attributes!(:status => 'Complete')
  end

  def mark_complete_if_done!
    if self.csv_upload_rows.where("status <> 'Complete'").count == 0
      self.mark_complete!
    end
  end

  def next_batch_of_incomplete_rows(maxrows=5)
    therows = self.csv_upload_rows.where("status <> 'Complete'").limit(maxrows).all
  end
  
end