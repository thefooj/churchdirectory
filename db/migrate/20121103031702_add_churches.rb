class AddChurches < ActiveRecord::Migration
  def change
    create_table :churches do |t|
      t.string :name
      t.string :urn
    end
    add_index :churches, :urn, :unique => true
  end
end
