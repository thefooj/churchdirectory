class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.references :church
      t.string :member_id
      t.string :first_name
      t.string :last_name
      t.string :household_id
      t.string :email_address
      t.string :street_address
      t.string :city
      t.string :zip_code
      t.string :phone
      t.string :mobile
      t.string :member_type
      t.string :member_age_category_name
      t.date :membership_date
      t.date :date_of_birth
      t.date :anniversary_date
      t.string :gender_name
      t.string :marital_status_name
      t.string :state
      t.string :country_name
      t.string :notes
    end
    add_index :people, :member_id, :unique => true
    add_index :people, :household_id
  end
end
