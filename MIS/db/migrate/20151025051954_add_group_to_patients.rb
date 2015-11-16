class AddGroupToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :group, :string
  end
end
