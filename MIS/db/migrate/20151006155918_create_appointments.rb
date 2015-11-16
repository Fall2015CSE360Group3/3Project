class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :patient_id
      t.integer :doctor_id
      t.text :description
      t.datetime :date_time
      t.timestamps null: false
    end
  end
end
