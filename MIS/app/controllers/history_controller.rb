class HistoryController < ApplicationController

  before_filter:relogin
  
  def index
    #Get the patient with the ID sent to this action as a parameter from the Patient table.  Store the retrieved patient in an instance variable:
    @currentPatient = Patient.find_by_id(params[:id])
    #Get all history items from the History database that have a patient_id matching the ID sent to this action as a parameter.  Store the array of returned history items in an instance variable:
  @histories = History.where(:patient_id => params[:id]).all
  #Create some personalized header text to show at the top of the index viewe:
  @headertext = @currentPatient[:name_first] + " "+ @currentPatient[:name_last]+"'s Medical History"
  #Only doctors, nurses, patients, HSP staff, and admins can edit medical history
  @allowEdit = filter_action(["ADMIN", "NURSE", "DOCTOR", "PATIENT", "HSPSTAFF"])
  #only admins can delete medical history items from index page
  @allowDelete = filter_action(["ADMIN"])
  #get the URL to the current user's main page:
  @main_route = main_route()
  end

  def create

  end

  def create_submit
    @history = History.create(:patient_id => params[:patient_id], :description => params[:description], :date => params[:date])
  #Go back to the index view, and pass the ID of the patient whose medical history we want to see:
  redirect_to :action => 'index', :id => params[:patient_id]
  end

  def edit
    @editHistory = History.find_by_id(params[:history_id])#get the history item that we are editing
  end

  def edit_submit
    @editHistory = History.find_by_id(params[:history_id])#find history by id from edit action
    @patient_id = @editHistory[:patient_id]#get the id of the patient with the editted history item
    @editHistory.update_attributes(:patient_id => @patient_id, :description => params[:description], :date => params[:date])
    redirect_to :action => 'index', :id => @patient_id#return to patient's medical history
  end

  def delete
    if filter_action(["HSPSTAFF", "ADMIN"])
    	@patient_id = (History.find_by_id(params[:history_id]))[:patient_id]  #get ID of patient with history item to delete
      History.destroy(params[:history_id])#Delete history item from History table
    end
    redirect_to :action => 'index', :id => @patient_id#return to patient's medical history
  end

end
