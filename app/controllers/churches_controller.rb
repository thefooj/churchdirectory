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
    get_members
  end
  
  def mobile_directory
    get_church or show_404
    get_members
  end

  
  def clear_church_data
    get_church or show_404
    
    Person.delete_all(:church_id => @church.id)
    redirect_to church_path(@church)
  end
  
  def upload_csv_form
    get_church or show_404
    
  end
  
  
  def upload_csv
    get_church or show_404
    
    @results = []
    @message = ""
    @exception = nil
    @the_upload = nil
    if request.post? && params[:csvfile].present? && params[:csvfile].original_filename =~ /\.csv$/
      begin
        lines = File.open(params[:csvfile].path) {|f| f.read }.gsub(/\r\n?/,"\n").each_line.to_a
        @the_upload = CsvUpload.create(:church => @church, :header => lines[0], :num_rows => lines.count-1, :status => 'Initiated')
        1.upto(lines.count-1) do |idx|
          therow = @the_upload.csv_upload_rows.build(:rowtext => lines[idx], :status => 'NotStarted')
          therow.save!
        end
        @church.clear_prior_people!
        @message = "Successfully uploaded your file"
      rescue => e
        @message = "Problem uploading -- Please check your file"
        Rails.logger.debug("Error:" + e.backtrace.join("\n"))
        @exception = e 
      end
    else
      @message = "Nothing to import -- no file provided, or it's not a .xls file"
    end
  end
  
  def handle_upload_update
    get_church or show_404
    upload_id = params[:upload_id]
    
    @the_upload = @church.csv_uploads.where(:id => upload_id).first
    if @the_upload.present?
      @people_imported = @church.import_directory_info_from_church_membership_online_csv(@the_upload, 10)
      if @people_imported.count > 0
        @message = "Imported #{@people_imported.count} people.  #{@the_upload.percent_complete}% complete"
      end
      
      if @the_upload.reload.complete?
        @church.update_all_sort_names_and_household_statuses!
        @message = "DONE: Imported everyone!"
      end
    end
  end
  
  protected
  
  def get_church
    @church = Church.find_by_urn(params[:id])
    return false if @church.nil?
    @church
  end
  
  def get_members
    @members = @church.members
    @non_attending_members = @church.non_attending_members
    @households = @church.sorted_households    
  end
  
end