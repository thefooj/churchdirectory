class ChurchesController < ApplicationController
  def index
    @churches = Church.all
  end
  
  def show
    get_church or show_404

  end
  
  def google_kml
    get_church or show_404
    @members_by_address = @church.members_by_address
  end
  
  def directory
    get_church or show_404

    @members = @church.members
    @non_attending_members = @church.non_attending_members
    @households = @church.sorted_households    
  end
  
  def clear_church_data
    get_church or show_404
    
    Person.delete_all(:church_id => @church.id)
    redirect_to church_path(@church)
  end
  
  def update_church_data
    get_church or show_404
    
    @results = []
    @message = ""
    @exception = nil
    if request.post? && params[:xlsfile].present? && params[:xlsfile].original_filename =~ /\.xls$/
      begin
        localtmpfilename = "#{Rails.root}/tmp/#{rand(1000000000)}.xls"
        FileUtils.cp("#{params[:xlsfile].path}", localtmpfilename)
        @people = @church.import_directory_info_from_church_membership_online(localtmpfilename)
        @message = "Successfully imported your file.  Please see below for details."
      rescue => e
        @message = "Problem uploading -- Please check your file"
        @exception = e 
      end
    else
      @message = "Nothing to import -- no file provided, or it's not a .xls file"
    end
  end
  
  protected
  
  def get_church
    @church = Church.find_by_urn(params[:id])
    return false if @church.nil?
    @church
  end
end