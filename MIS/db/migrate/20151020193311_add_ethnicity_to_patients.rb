class AddEthnicityToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :ethnicity, :string
  end
end
