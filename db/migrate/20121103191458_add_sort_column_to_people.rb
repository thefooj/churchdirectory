class AddSortColumnToPeople < ActiveRecord::Migration
  def change
    add_column :people, :sort_name, :string
    add_column :people, :is_head_of_household, :boolean, :default => false
    add_column :people, :is_spouse_of_head_of_household, :boolean, :default => false
  end
end
