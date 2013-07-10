class CreateChurchUsers < ActiveRecord::Migration
  def change
    create_table :church_users do |t|
      t.references :church
      t.references :user
      t.boolean :admin
    end
    add_index :church_users, [:church_id,:user_id], :unique => true
    add_index :church_users, :user_id
  end
end
