class DoctorsController < ApplicationController

	before_filter:relogin, :except => ["login", "login_submit"]

  def index
  	#get liust of all doctors in the Doctors table:
	@doctors = Doctor.all
	#Only show Edit and Delete options if the current user is an admin:
	@valid = filter_action(["ADMIN"])
	#get URL to current user's main page:
	@main_route = main_route()
  end
  
  def login
	  p "DOCTOR_LOGIN"
  end
  
  def login_submit
  	  p params[:username]
	  @docUser = authenticate(params[:username])
	  if @docUser == false
		redirect_to :action => 'login'#Redirect to the doctor login screen if login failed
	  else
		  session[:firstname] = @docUser[:name_first]#Store name in session
		  session[:lastname] = @docUser[:name_last]
		  session[:access_id] = "DOCTOR" #Set access identifier
		  session[:user_id] = @docUser[:id] #Store user ID for the current user during this session
		  p "USER NAME IS:" + session[:firstname] + " "+ session[:lastname]
		  p "USER IS A: " + session[:access_id]
		  redirect_to :action => 'main' #call main action of this controller to go to the doctor's main page
	  end
  end
  
  def main
	@firstname = session[:firstname]
	@lastname = session[:lastname]
	@numAlerts = Alert.all.length
  end
  
  def register
	
  end
  
  def register_submit
  	#Create a new doctor entry in the Doctor table with the parameters entered in the register view: 
	@doctor = Doctor.create(:name_first => params[:first_name], :name_last => params[:last_name], :specialty => params[:specialty])
	redirect_to :action => 'index'#go back to the index of dcotors
  end

  #edit and edit_submit expect a parameter "id" that contains the id of the doctor to edit:
  def edit
  	#Get doctor entry to edit from database, store in editDoctor variable:
  	@editDoctor = Doctor.find_by_id(params[:id])
  end

  def edit_submit
  	@editDoctor = Doctor.find_by_id(params[:id])
  	#Save changes back into the database:
  	@editDoctor.update_attributes(:name_first => params[:first_name], :name_last => params[:last_name], :specialty => params[:specialty])
  	#Go back to the doctor index:
	redirect_to :action => 'index'
  end

  
  def authenticate(username="")
	@loginDoctor = Doctor.find_by_id(username[2..-1])
	if @loginDoctor == nil
		return false
	else
		if @loginDoctor[:name_first][0] == username[0] && @loginDoctor[:name_last][0] == username[1]
			p "NAME MATCHES INITIALS"
			return @loginDoctor
		else
			return false
		end
	end
  end


def alerts
	@alerts = Alert.all
	@main_route = main_route()
end

  
  def delete
  	#only admins can delete doctors
  	if filter_action(["ADMIN"]) == true
		Doctor.destroy(params[:id])
		p "DELETED"
	end
	redirect_to :action => 'index' #go back to doctor index
  end
  
  def logout
  	#set all session variables to nil o logout
	session[:access_id] = nil
	session[:firstname] = nil
	session[:lastname] = nil
	session[:user_id] = nil
	redirect_to :controller => 'welcome', :action => 'main'
  end
  
end
