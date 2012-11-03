class ChurchesController < ApplicationController
  def index
    @churches = Church.all
  end
  
  def show
    get_church or show_404

    @members = @church.members
    @non_attending_members = @church.non_attending_members
    @households = @church.sorted_households    
  end
  
  def update_church_data
    get_church or show_404
    
    # TODO - import excel
  end
  
  protected
  
  def get_church
    @church = Church.find_by_urn(params[:id])
    return false if @church.nil?
    @church
  end
end