class HspstaffsController < ApplicationController

  before_filter:relogin, :except => ["login", "login_submit"]
  
  def login
  p "HSP_STAFF_LOGIN"
  end
  
  def login_submit
	  @hspUser = authenticate(params[:username])
	  if @hspUser == false
		redirect_to :action => 'login'#Redirect to the HSP staff login screen if login failed
	  else
		  session[:firstname] = @hspUser[:name_first]#Store name in session
		  session[:lastname] = @hspUser[:name_last]
		  session[:access_id] = "HSPSTAFF"
		  session[:user_id] = @hspUser[:id]
		  p "USER NAME IS:" + session[:firstname] + " "+session[:lastname]
		  p "USER IS A: " + session[:access_id]
		  redirect_to :action => 'main' #redirect to the HSP staff main page if login succeeded
	  end
  end
  
  def index
    @hspstaffs = Hspstaff.all
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
    @hspstaff = Hspstaff.create(:name_first => params[:first_name], :name_last => params[:last_name])
	redirect_to :action => 'index'
  end
  
  #edit and edit_submit expect a parameter "id" that contains the id of the HSP staff member to edit:
  def edit
  	#Get HSP staff entry to edit from database, store in editHSP variable:
  	@editHSP = Hspstaff.find_by_id(params[:id])
  end

  def edit_submit
  	@editHSP = Hspstaff.find_by_id(params[:id])
  	#Save changes back into the database:
  	@editHSP.update_attributes(:name_first => params[:first_name], :name_last => params[:last_name])
  	#Go back to the HSP staff index:
	redirect_to :action => 'index'
  end

  def authenticate(username="")
	@loginHSP = Hspstaff.find_by_id(username[2..-1])
	if @loginHSP == nil
		return false
	else
		if @loginHSP[:name_first][0] == username[0] && @loginHSP[:name_last][0] == username[1]
			p "NAME MATCHES INITIALS"
			return @loginHSP
		else
			return false
		end
	end
  end
  
  def delete
    #only admins can delete HSP staff
  if filter_action(["ADMIN"]) == true
    Hspstaff.destroy(params[:id])
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


  def generate
    
  end


end
