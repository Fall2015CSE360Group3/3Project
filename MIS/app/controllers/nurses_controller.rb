class NursesController < ApplicationController

  before_filter:relogin, :except => ["login", "login_submit"]
	
  def login
  p "NURSE_LOGIN"
  end
  
  def login_submit
  	  p params[:username]
	  @nurseUser = authenticate(params[:username])
	  if @nurseUser == false
		redirect_to :action => 'login'#Redirect to the nurse login screen if login failed
	  else
		  session[:firstname] = @nurseUser[:name_first]#Store name in session
		  session[:lastname] = @nurseUser[:name_last]
		  session[:access_id] = "NURSE"
		  session[:user_id] = @nurseUser[:id]
		  p "USER NAME IS:" + session[:firstname] + " "+session[:lastname]
		  p "USER IS A: " + session[:access_id]
		  redirect_to :action => 'main'#Redirect to the nurse main screen if login succeeded
	  end
  end
  
  def index
  	#get all nurses in the Nurse table
	@nurses = Nurse.all
	#only admins can view/edit/add nurses
  	@valid = filter_action(["ADMIN"])
	@main_route = main_route()
  end
  
  def main
	@firstname = session[:firstname]
	@lastname = session[:lastname]
  end
  
  def register
	
  end
  
  def register_submit
	@nurse = Nurse.create(:name_first => params[:first_name], :name_last => params[:last_name])
	redirect_to :action => 'index'
  end

  #edit and edit_submit expect a parameter "id" that contains the id of the nurse to edit:
  def edit
  	#Get nurse entry to edit from database, store in editNurse variable:
  	@editNurse = Nurse.find_by_id(params[:id])
  end

  def edit_submit
  	@editNurse = Nurse.find_by_id(params[:id])
  	#Save changes back into the database:
  	@editNurse.update_attributes(:name_first => params[:first_name], :name_last => params[:last_name])
  	#Go back to the nurse index:
	redirect_to :action => 'index'
  end
  
  def authenticate(username="")
	@loginNurse = Nurse.find_by_id(username[2..-1])
	if @loginNurse == nil
		return false
	else
		if @loginNurse[:name_first][0] == username[0] && @loginNurse[:name_last][0] == username[1]
			p "NAME MATCHES INITIALS"
			return @loginNurse
		else
			return false
		end
	end
  end
  
  def delete
  	#only admins can delete nurses
  	if filter_action(["ADMIN"]) == true
		Nurse.destroy(params[:id])
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
