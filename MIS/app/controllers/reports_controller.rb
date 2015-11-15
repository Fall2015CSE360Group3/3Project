class ReportsController < ApplicationController

	  before_filter:relogin

def ages
	@main_route = main_route()
	@counts = Array.new()
	@total = Patient.all.length
	@counter = 0
	@oldest = Patient.minimum("dob")
	if @total != 0
		while Date.today.years_ago(@counter*10) >= @oldest  do#keep looping while the age range where the oldest patient is has not been checked
			@result = Patient.where("dob >= ? AND dob < ?", Date.today.years_ago((10 * @counter)+10), Date.today.years_ago(@counter * 10) ).all
			@counts.push(@result.length)
			@counter += 1
		end
	end
end

def genders
	@main_route = main_route()
	@counts = Array.new(2)
	@total = Patient.all.length
	if @total != 0	
		@counts[0] = Patient.where(:gender => "Male").all.count
		@counts[1] = Patient.where(:gender => "Female").all.count
	end
end

def ethnicities
	@main_route = main_route()
	@counts = Array.new(6)
	@total = Patient.all.length
	if @total != 0
		@counts[0] = Patient.where("ethnicity = ? OR ethnicity = ?", "White/Caucasian", "").all.count
		@counts[1] = Patient.where(:ethnicity => "Black/African American").all.count
		@counts[2] = Patient.where(:ethnicity => "Asian").all.count
		@counts[3] = Patient.where(:ethnicity => "Hispanic").all.count
		@counts[4] = Patient.where(:ethnicity => "Native American").all.count
		@counts[5] = Patient.where(:ethnicity => "Other").all.count
	end
end

def outcomes
	@main_route = main_route()
	@counts = Array[0, 0, 0, 0]
	@total = Patient.all.length
	if @total != 0
		#get number of patients with no reported health issues
		(Patient.all).each do |patient|
			@cndCount = Condition.where("patient_id = ?", patient.id).all.count
			p @cndCount
			if @cndCount == 0
				@counts[0] = @counts[0] + 1
			end
		end

		#get number of patients with reported health issues
		(Patient.all).each do |patient|
			@cndCount = Condition.where("patient_id = ?", patient.id).all.count
			if @cndCount != 0
				@counts[1] = @counts[1] + 1
			end
		end

		#get number of patients with issues reported in the last month
		(Patient.all).each do |patient|
			@cndCount = Condition.where("patient_id = ? AND created_at >= ?", patient.id, Date.today.months_ago(1)).all.count
			if @cndCount != 0
				@counts[2] = @counts[2] + 1
			end
		end

			#get number of patients with issues reported in the last 6 months
		(Patient.all).each do |patient|
			@cndCount = Condition.where("patient_id = ? AND created_at >= ?", patient.id, Date.today.months_ago(6)).all.count
			if @cndCount != 0
				@counts[3] = @counts[3] + 1
			end
		end
	end

end

def groups
	@main_route = main_route()
	@counts = Array.new(5)
	@total = Patient.all.length
	if @total != 0
		@counts[0] = Patient.where(:group => "General").all.count
		@counts[1] = Patient.where(:group => "Intensive Care").all.count
		@counts[2] = Patient.where(:group => "Recovery").all.count
		@counts[3] = Patient.where(:group => "Surgery").all.count
		@counts[4] = Patient.where(:group => "Cancer Treatment").all.count
	end
end

def registration_dates
	@main_route = main_route()
	@counts = Array.new()
	@dates = Array.new()
	@total = Patient.all.length
	@counter = 0
	@oldest = Patient.minimum("created_at")
	if @total != 0
		while DateTime.now.months_ago(@counter) >= @oldest  do#keep looping while the age range where the oldest patient is has not been checked
			@result = Patient.where("created_at >= ? AND created_at < ?", Date.today.months_ago(@counter).beginning_of_month, Date.today.months_ago(@counter).end_of_month).all
			@dates.push(Date.today.months_ago(@counter).strftime("%m-%Y"))
			@counts.push(@result.length)
			@counter += 1
		end
	end
end

def select
	
end

end