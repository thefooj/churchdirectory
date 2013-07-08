class SplitUploads < ActiveRecord::Migration
  def change
    create_table :csv_uploads do |t|
      t.references :church
      t.text :header
      t.integer :num_rows
      t.string :status
      t.timestamps
    end
    add_index :csv_uploads, :status
    add_index :csv_uploads, :church_id
    
    create_table :csv_upload_rows do |t|
      t.references :csv_upload
      t.text :rowtext
      t.string :status
    end
    add_index :csv_upload_rows, :csv_upload_id
      
  end

end
