class PrescriptionController < ApplicationController

  before_filter:relogin
  
  def index
    #Get the patient with the ID sent to this action as a parameter from the Patient table.  Store the retrieved patient in an instance variable:
    @currentPatient = Patient.find_by_id(params[:id])
    #Get all prescriptions from the Prescription database that have a patient_id matching the ID sent to this action as a parameter.  Store the array of returned prescriptions in an instance variable:
    @prescriptions = Prescription.where(:patient_id => params[:id]).all
    #Create some personalized header text to show at the top of the index viewe:
    @headertext = @currentPatient[:name_first] + " "+ @currentPatient[:name_last]+"'s Prescriptions"
    #Only doctors and admins can edit, create, or delete prescriptions.  Patients, nurses, and HSP staff can only view existing prescriptions
    @allowEdit = filter_action(["ADMIN", "DOCTOR"])
    #get the URL to the current user's main page:
    @main_route = main_route()
  end

  def create

  end

  def create_submit#expects the ID of the patient with this prescription as a parameter
    #Create a new prescription entry in the Prescription table with the parameters entered in the create view: 
    @prescription = Prescription.create(:patient_id => params[:patient_id], :name => params[:name], :dosage => params[:dosage])
  #Go back to the index view, and pass the ID of the patient whose prescriptions we want to see:
  redirect_to :action => 'index', :id => params[:patient_id]
  end

  def edit#expects the ID of a prescription to edit as a parameter
    @editPrescription = Prescription.find_by_id(params[:prescription_id])#get the prescription that we are editing
  end

  def edit_submit#expects ID of prescription just edited as parameter
    @editPrescription = Prescription.find_by_id(params[:prescription_id])#find prescription by id from edit action
    @patient_id = @editPrescription[:patient_id]#get the id of the patient with the editted prescription
    @editPrescription.update_attributes(:patient_id => @patient_id, :name => params[:name], :dosage => params[:dosage])
    redirect_to :action => 'index', :id => @patient_id#return to patient's index of prescriptions
  end

  def delete#expects ID of prescription to delete as a parameter
  	    #only admins, doctors, HSP staff can delete prescriptions 
    if filter_action(["ADMIN", "DOCTOR", "HSPSTAFF"])
       @patient_id = (Prescription.find_by_id(params[:prescription_id]))[:patient_id]  #get ID of patient with prescription to delete
       Prescription.destroy(params[:prescription_id])#Delete prescription from Prescription table
    end
    redirect_to :action => 'index', :id => @patient_id#return to patient's index of prescriptions
  end

end
