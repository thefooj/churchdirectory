class AddGeocodes < ActiveRecord::Migration
  def change
    add_column :people, :longitude, :float
    add_column :people, :latitude, :float
  end
end
