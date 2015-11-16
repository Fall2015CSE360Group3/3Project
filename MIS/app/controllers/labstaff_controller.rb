class LabstaffController < ApplicationController
  
  before_filter:relogin, :except => ["login", "login_submit"]

  def login
	p "LABSTAFF LOGIN"
  end
  
  def login_submit
  	  @labUser = authenticate(params[:username])
	  if @labUser == false
		redirect_to :action => 'login'#Redirect to the doctor login screen if login failed
	  else
		  session[:firstname] = @labUser[:name_first]#Store name in session
		  session[:lastname] = @labUser[:name_last]
		  session[:access_id] = "LABSTAFF"
		  session[:user_id] = @labUser[:id]
		  p "USER NAME IS:" + session[:firstname] + " "+session[:lastname]
		  p "USER IS A: " + session[:access_id]
		  redirect_to :action => 'main'
	  end
  end
  
  def main
    @firstname = session[:firstname]
	@lastname = session[:lastname]
	@patients = Patient.all
  end
  
  def index
	@labstaffs = Labstaff.all
  	@valid = filter_action(["ADMIN"])
	@main_route = main_route()
  end
  
  def register
	
  end
  
  def register_submit
	@labstaff = Labstaff.create(:name_first => params[:first_name], :name_last => params[:last_name])
	redirect_to :action => 'index'
  end
  
  #edit and edit_submit expect a parameter "id" that contains the id of the lab staff to edit:
  def edit
  	#Get lab staff entry to edit from database, store in editLab variable:
  	@editLab = Labstaff.find_by_id(params[:id])
  end

  def edit_submit
  	@editLab = Labstaff.find_by_id(params[:id])
  	#Save changes back into the database:
  	@editLab.update_attributes(:name_first => params[:first_name], :name_last => params[:last_name])
  	#Go back to the lab staff index:
	redirect_to :action => 'index'
  end

  def authenticate(username="")
	@loginLab = Labstaff.find_by_id(username[2..-1])
	if @loginLab == nil
		return false
	else
		if @loginLab[:name_first][0] == username[0] && @loginLab[:name_last][0] == username[1]
			p "NAME MATCHES INITIALS"
			return @loginLab
		else
			return false
		end
	end
  end
  
  def delete
  	#Only admins can delete Lab staff
  	if filter_action(["ADMIN"]) == true
		Labstaff.destroy(params[:id])
		p "DELETED"
	end
	redirect_to :action => 'index'
  end
  
  def logout
	session[:access_id] = nil
	session[:firstname] = nil
	session[:lastname] = nil
	session[:user_id] = nil
	redirect_to :controller => 'welcome', :action => 'main'
  end
end
