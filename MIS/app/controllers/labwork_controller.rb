class LabworkController < ApplicationController

  before_filter:relogin
  
  def index
    @allowCreate = filter_action(["ADMIN", "DOCTOR"])#only admins/doctors can reques labwork
    @allowEdit = filter_action(["LABSTAFF"])#only labstaff can edit an existing labwork request
    @allowDelete = filter_action(["ADMIN"])#only admins can delete labwork
    #Get the patient with the ID sent to this action as a parameter from the Patient table.  Store the retrieved patient in an instance variable:
    @currentPatient = Patient.find_by_id(params[:id])
    #Get all labwork from the Labwork database that have a patient_id matching the ID sent to this action as a parameter.  Store the array of returned labworks in an instance variable:
    @labworks = Labwork.where(:patient_id => params[:id]).all
    #Create some personalized header text to show at the top of the index viewe:
    @headertext = @currentPatient[:name_first] + " "+ @currentPatient[:name_last]+"'s Lab Work"
    @main_route = main_route()
  end

  def create

  end

  def create_submit#expects the ID of the patient with this labwork as a parameter
    #Create a new labwork entry in the Labwork table with the parameters entered in the create view: 
    @labwork = Labwork.create(:patient_id => params[:patient_id], :description => params[:description], :complete => false, :data => nil)
  #Go back to the index view, and pass the ID of the patient whose labwork we want to see:
  redirect_to :action => 'index', :id => params[:patient_id]

  end

  def edit#expects the ID of the labwork to edit as a parameter
    @editLabwork = Labwork.find_by_id(params[:labwork_id])#get the labwork that we are editing

  end

  def edit_submit
    @editLabwork = Labwork.find_by_id(params[:labwork_id])#find labwork by id from edit action
    #if needed, delete existing report file from uploads
    if @editLabwork.data != nil
      File.delete(Rails.root.join('public', 'uploads', @editLabwork.data))
    end
    #upload new report file to uploads folder
    File.open(Rails.root.join('public', 'uploads', params[:upload_file].original_filename), 'wb') do |file|
      file.write(params[:upload_file].read)
    end
    @patient_id = @editLabwork[:patient_id]#get the id of the patient with the editted labwork
    @editLabwork.update_attributes(:complete => true, :data => params[:upload_file].original_filename)#save filename of report in Labwork table
    redirect_to :action => 'index', :id => @patient_id#return to patient's index of labwork
  end

  def download
    send_file(Rails.root.join('public', 'uploads', params[:labwork_file]))
  end

  def delete
        #only admins, hsp staff can delete labwork 
    if filter_action(["ADMIN", "HSPSTAFF"])
       @labworkToDelete = Labwork.find_by_id(params[:labwork_id])
       @patient_id = @labworkToDelete.patient_id  #get ID of patient with labwork to delete
       if @labworkToDelete.data != nil
        File.delete(Rails.root.join('public', 'uploads', @labworkToDelete.data))       
       end
       Labwork.destroy(params[:labwork_id])#Delete labwork from Labwork table
    end
    redirect_to :action => 'index', :id => @patient_id#return to patient's index of labwork
  end

end
