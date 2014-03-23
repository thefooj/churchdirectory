class AddChurchImages < ActiveRecord::Migration
  def change
    add_attachment :churches, :no_pic
    add_attachment :churches, :big_logo
  end
end
