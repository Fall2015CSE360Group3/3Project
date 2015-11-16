class AppointmentController < ApplicationController

  before_filter:relogin

  def index
  	#Get all appointments for the patient with the ID passed as a parameter:
    @currentPatient = Patient.find_by_id(params[:id])
	 @appointments = Appointment.where(:patient_id => params[:id]).all
	 @headertext = @currentPatient[:name_first] + " "+ @currentPatient[:name_last]+"'s Visit History"
	 @allowDelete = filter_action(["ADMIN"])#only admins can delete appointments from the index view (Patients create new appointments from the main view)
   @allowNew = filter_action(["ADMIN"])#only admins can add appointmenrs from rhe appointment index
  @main_route = main_route()
  end
  
  def create
	
  end

  def create_submit
    p "CREATE_SUBMIT"
    @d = Date.parse(params[:date])#create a time object from the date string returned by the form
    #Assemble datetime object from 
    @date_time = DateTime.new(@d.year.to_i, @d.month.to_i, @d.day.to_i, params["time(4i)"].to_i, params["time(5i)"].to_i)
    p @date_time.strftime("%I:%M%p")
    @appointment = Appointment.create(:patient_id => params[:patient_id], :doctor_id => params[:doctor_id], :date_time => @date_time)
	  redirect_to :action => 'index', :id => params[:patient_id]
  end

  def delete
    if filter_action(["ADMIN", "HSPSTAFF"])
       @patient_id = (Appointment.find_by_id(params[:appointment_id]))[:patient_id]  #get ID of patient with appointment to delete
       Appointment.destroy(params[:appointment_id])#Delete appointment from appointment table
    end
    redirect_to :action => 'index', :id => @patient_id#return to patient's index of appointments
  end
end
