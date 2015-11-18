class PatientsController < ApplicationController

    
  before_filter:relogin, :except => ["login", "login_submit"]

	    @@raceList = 
      ["White/Caucasian", 
        "Black/African American", 
        "Asian",
        "Hispanic",
        "Native American",
        "Other"]



  def login
    p "PATIENT_LOGIN"
  end
  
  def login_submit
  	  @patientUser = authenticate(params[:username])
	  if @patientUser == false
		redirect_to :action => 'login'#Redirect to the doctor login screen if login failed
	  else
		  session[:firstname] = @patientUser[:name_first]#Store name in session
		  session[:lastname] = @patientUser[:name_last]
		  session[:access_id] = "PATIENT"
		  session[:user_id] = @patientUser[:id]
		  p "USER NAME IS:" + session[:firstname] + " "+session[:lastname]
		  p "USER IS A: " + session[:access_id]
		  redirect_to :action => 'main'
	  end
  end
  
  def index
	@patients = Patient.all
  	@valid = filter_action(["ADMIN", "HSPSTAFF"]) #Allow admin AND HSP staff to add, delete, edit Patient info
  	@showConditions = filter_action(["ADMIN", "DOCTOR", "NURSE", "PATIENT"]) #HSP staff cannot view/edit conditions of patients
	@main_route = main_route()
  end
  
  def update_group
  	@editPatient = Patient.find_by_id(params[:patient_id])
  	@editPatient.update_attributes(:group => params[:selGroup])
  	redirect_to :controller => 'condition', :action => 'index', :id => params[:patient_id]
  end


  def main
  	@firstname = session[:firstname]
	@lastname = session[:lastname]
	@sendAlertLink = true
	if Condition.where("patient_id = ?", session[:user_id]).length == 0
		@sendAlertLink = false
	end
  end

  def send_alert
  	@main_route = main_route()
  	@existingAlert = Alert.where("patient_id = ?", session[:user_id])
  	if @existingAlert.length == 0 #no existng alerts, need to make a new one
      @newAlert = Alert.create(:patient_id => session[:user_id])
    end
  end
  
  def register
  	@races = @@raceList
  end
  
  def register_submit
	@patient = Patient.create(:name_first => params[:first_name], :name_last => params[:last_name], :gender => params[:gender], :ssn => params[:ssn], :hip => params[:hip], :address => params[:address], :phone => params[:phone], :dob => params[:dob], :weight => params[:weight], :height => params[:height], :ethnicity => params[:ethnicity], :group => "General" )
	redirect_to :action => 'index'
  end

  #edit and edit_submit take a parameter that is the id of the patient to edit and save changes for
  def edit
  	@races = @@raceList
  	@editPatient = Patient.find_by_id(params[:id])
  end

  def edit_submit
  	@editPatient = Patient.find_by_id(params[:id])
  	#Write changes to selected patient back to the database:
  	@editPatient.update_attributes(:name_first => params[:first_name], :name_last => params[:last_name], :gender => params[:gender], :ssn => params[:ssn], :hip => params[:hip], :address => params[:address], :phone => params[:phone], :dob => params[:dob], :weight => params[:weight], :height => params[:height], :ethnicity => params[:ethnicity] )
	#Return to the patient index:
	redirect_to :action => 'index'  
  end
  
  def authenticate(username="")
	@loginPatient = Patient.find_by_id(username[2..-1])
	if @loginPatient == nil
		return false
	else
		if @loginPatient[:name_first][0] == username[0] && @loginPatient[:name_last][0] == username[1]
			p "NAME MATCHES INITIALS"
			return @loginPatient
		else
			return false
		end
	end
  end
  
  def delete
  	#Only admins OR HSP staff can delete patients
	if filter_action(["ADMIN", "HSPSTAFF"]) == true
		Patient.destroy(params[:id])
		#destroy all data associated with deleted patient
		Appointment.destroy_all(:patient_id => params[:id])
		Condition.destroy_all(:patient_id => params[:id])
		History.destroy_all(:patient_id => params[:id])
		Labwork.destroy_all(:patient_id => params[:id])
		Prescription.destroy_all(:patient_id => params[:id])

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
