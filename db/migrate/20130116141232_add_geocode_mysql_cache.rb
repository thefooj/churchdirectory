class AddGeocodeMysqlCache < ActiveRecord::Migration
  def change
    create_table :geocode_caches do |t|
      t.string :key
      t.text :value
    end
    add_index :geocode_caches, :key
  end
end
