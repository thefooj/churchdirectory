class AddChurchInfo < ActiveRecord::Migration
  def change
    add_column :churches, :short_name, :string
    add_column :churches, :address1, :string
    add_column :churches, :address2, :string
    add_column :churches, :city, :string
    add_column :churches, :state, :string
    add_column :churches, :zip, :string
    add_column :churches, :website, :string
    add_column :churches, :phone, :string
    add_column :churches, :front_page_content, :text

  end
end
