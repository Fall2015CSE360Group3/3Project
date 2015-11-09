class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
#-------------------------------------------------------------------
#All controllers inherit from the ApplicationController (ApplicationController is the base class for all controllers)
#All controllers inherit the actions defined in this controller


#filter_action accepts an array of strings.  If the session variable access_id matches one of the strings in the array,
#the action returns true:
  def filter_action(filter = [])
	if session[:access_id] == nil
		return false
	else
		filter.each do |filter_item|
			if filter_item == session[:access_id]
				return true
			end
		end
	return false
  end
  end

  def relogin()
  	#p "ACCESS ID: " + session[:access_id]
  	if session[:access_id] == nil
  		redirect_to :controller => "welcome", :action => "main"
  	end
  end


  def main_route() #returns route to the main page of the current user type (Used for setting the destination of the "Back" links on index pages)
	if session[:access_id] == "ADMIN"
		return "/admin/main"
	elsif session[:access_id] == "PATIENT"
		return "/patients/main"
	elsif session[:access_id] == "DOCTOR"
		return "/doctors/main"
	elsif session[:access_id] == "NURSE"
		return "/nurses/main"
	elsif session[:access_id] == "HSPSTAFF"
		return "/hspstaffs/main"
	elsif session[:access_id] == "LABSTAFF"
		return "/labstaff/main"
	elsif session[:access_id] == "PHARMACIST"
		return "/pharmacist/main"
	end
  end
end
