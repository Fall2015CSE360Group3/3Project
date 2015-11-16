class Patient < ActiveRecord::Base

def age
	Date.today.year - dob.year
end

end
