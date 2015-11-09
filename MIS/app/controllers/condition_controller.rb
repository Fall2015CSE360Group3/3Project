class ConditionController < ApplicationController

  before_filter:relogin

    @@symptomList = 
      ["Chest pain", 
        "Headache", 
        "Upset stomach",
        "Numbness",
        "Sore throat",
        "Body aches",
        "Nausea",
        "Difficulty breathing",
        "High blood pressure",
        "Abdominal pain",
        "Fatigue",
        "Constipation",
        "Vision problems",
        "Dizziness",
        "Hearing problems",
        "Frequent urination",
        "Other"]

    @@severities = 
    [5,
      3,
      2,
      4,
      2,
      2,
      3,
      5,
      4,
      3,
      2,
      2,
      3,
      3,
      3,
      4,
      1]

      @@groupConditions = 
      ["General",
        "Intensive Care",
        "Recovery",
        "Surgery",
        "Cancer Treatment",
      ]


  def calculate_severity(patientID = "")
    @recentConditions = Condition.where("created_at >= ? AND patient_id = ?", 7.days.ago, patientID)
    @severitySum = 0;
    if @recentConditions.length != 0
      @recentConditions.each do |symptom|
        p "SEVERITY OF " + (symptom.condition).to_s + " IS " + @@severities[(@@symptomList.index(symptom.condition))].to_s
        @severitySum = @severitySum + @@severities[(@@symptomList.index(symptom.condition))]
      end
      @severitySum = @severitySum/@recentConditions.length.to_f
      p "SEVERITY SUM IS " + @severitySum.to_s
    end
    return @severitySum
  end

  def index
    @groups = @@groupConditions
    @showGroup = filter_action(["ADMIN", "DOCTOR", "NURSE"])
  	#Get the patient with the ID sent to this action as a parameter from the Patient table.  Store the retrieved patient in an instance variable:
  	@currentPatient = Patient.find_by_id(params[:id])
  	#Get all conditions from the Condition database that have a patient_id matching the ID sent to this action as a parameter.  Store the array of returned conditions in an instance variable:
	@conditions = Condition.where(:patient_id => params[:id]).all
	#Create some personalized header text to show at the top of the index viewe:
	@headertext = @currentPatient[:name_first] + " "+ @currentPatient[:name_last]+"'s Health Conditions"
	#Only doctors, nurses, and admins can edit an existing condtion.  Patients can only add new conditions and view the conditions they added
  @allowEdit = filter_action(["ADMIN", "NURSE", "DOCTOR"])
  #get the URL to the current user's main page:
	@main_route = main_route()
  end

  def create

    @symptoms = @@symptomList

  	#show_doctors_notes is only true if current user is an admin, nurse, doctor, or patient
    #Patients can write notes when creating a condition, but cannot edit them afterthe condtion is created
  	@show_doctors_notes = filter_action(["ADMIN", "NURSE", "DOCTOR", "PATIENT"])
  end

  def create_submit#expects the ID of the patient this condition applies to as a parameter
  	#Create a new condition entry in the Condition table with the parameters entered in the create view: 
  	@condition = Condition.create(:patient_id => params[:patient_id], :condition => params[:condition], :notes => params[:notes])
    @severity = calculate_severity(params[:patient_id])
    @existingAlert = Alert.where("patient_id = ?", params[:patient_id])#check if an alert exists for this patient
    if @severity >= 3.5 && @existingAlert.length == 0
      @newAlert = Alert.create(:patient_id => params[:patient_id])
    end

	#Go back to the index view, and pass the ID of the patient whose conditions we want to see:
	redirect_to :action => 'index', :id => params[:patient_id]
  end

  def edit#expects the ID of a condition to edit as a parameter
    @symptoms = @@symptomList
  	@editCondition = Condition.find_by_id(params[:condition_id])#get the condition that we are editing
  	@show_doctors_notes = filter_action(["ADMIN", "NURSE", "DOCTOR"])#only doctors, admins, and nurses can see/edit notes
  end

  def edit_submit
  	@editCondition = Condition.find_by_id(params[:condition_id])#find codition by id from edit action
  	@patient_id = @editCondition[:patient_id]#get the id of the patient with the editted condition
  	@editCondition.update_attributes(:patient_id => @patient_id, :condition => params[:condition], :notes => params[:notes])

    @severity = calculate_severity(@patient_id)
    @existingAlert = Alert.where("patient_id = ?", @patient_id)#check for existing alert for this patient
    if @severity >= 3.5 && @existingAlert.length == 0 #no existng alerts, need to make a new one
      @newAlert = Alert.create(:patient_id => @patient_id)
    end
    if @severity < 3.5 && @existingAlert.length != 0 #delete existing alert if severity is below threshhold
      @alert_id = @existingAlert[0].id#get id of alert entry to delete
      Alert.destroy(@alert_id)
    end

  	redirect_to :action => 'index', :id => @patient_id#return to patient's index of conditions
  end

  def delete#expects the ID of a condition to delete as a parameter
    #only admins, nurses, HSP staff, or doctors can delete medical conditions 
    if filter_action(["ADMIN", "NURSE", "DOCTOR", "HSPSTAFF"])
       @patient_id = (Condition.find_by_id(params[:condition_id]))[:patient_id]  #get ID of patient with condition to delete
       Condition.destroy(params[:condition_id])#Delete condition from Condition table
    end

    @severity = calculate_severity(@patient_id)
    @existingAlert = Alert.where("patient_id = ?", @patient_id)
    if @severity < 3.5 && @existingAlert.length != 0 #delete existing alert if severity is below threshhold
      @alert_id = @existingAlert[0].id
      Alert.destroy(@alert_id)
    end
    redirect_to :action => 'index', :id => @patient_id#return to patient's index of conditions
  end

end
