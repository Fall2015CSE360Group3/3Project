class AddHipToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :hip, :integer
  end
end
