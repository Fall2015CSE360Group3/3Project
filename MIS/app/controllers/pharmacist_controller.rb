class PharmacistController < ApplicationController

  before_filter:relogin, :except => ["login", "login_submit"]

  def login
	p "PHARMACIST LOGIN"
  end
  
  def login_submit
	  @pharmacistUser = authenticate(params[:username])
	  if @pharmacistUser == false
		redirect_to :action => 'login'#Redirect to the nurse login screen if login failed
	  else
		  session[:firstname] = @pharmacistUser[:name_first]#Store name in session
		  session[:lastname] = @pharmacistUser[:name_last]
		  session[:access_id] = "PHARMACIST"
		  session[:user_id] = @pharmacistUser[:id]
		  p "USER NAME IS:" + session[:firstname] + " "+session[:lastname]
		  p "USER IS A: " + session[:access_id]
		  redirect_to :action => 'main'
	  end
  end
  
  def index
	@pharmacists = Pharmacist.all
  	@valid = filter_action(["ADMIN"])
	@main_route = main_route()
  end
  
  def main
  	authenticate()
	@firstname = session[:firstname]
	@lastname = session[:lastname]
	@patients = Patient.all
  end
  
  def register
  
  end
  
  def register_submit
	@pharmacist = Pharmacist.create(:name_first => params[:first_name], :name_last => params[:last_name])
	redirect_to :action => 'index'
  end

  #edit and edit_submit take a parameter that is the id of the pharmacist to edit and save changes for
  def edit
  	@editPharmacist = Pharmacist.find_by_id(params[:id])
  end

  def edit_submit
  	@editPharmacist = Pharmacist.find_by_id(params[:id])
  	#Write changes to selected patient back to the database:
  	@editPharmacist.update_attributes(:name_first => params[:first_name], :name_last => params[:last_name])
	#Return to the patient index:
	redirect_to :action => 'index'  
  end
  
  def authenticate(username="")
	@loginPharmacist = Pharmacist.find_by_id(username[2..-1])
	if @loginPharmacist == nil
		return false
	else
		if @loginPharmacist[:name_first][0] == username[0] && @loginPharmacist[:name_last][0] == username[1]
			p "NAME MATCHES INITIALS"
			return @loginPharmacist
		else
			return false
		end
	end
  end
  
  def delete
  	#only admins can delete pharmacists
  	if filter_action(["ADMIN"]) == true
		Pharmacist.destroy(params[:id])
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
