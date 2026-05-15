class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.date :handover_date
      t.string :receiver_name
      t.string :receiver_employee_number
      t.string :receiver_branch_department
      t.boolean :is_consumable, default: false, null: false
      t.boolean :is_custody, default: false, null: false
      t.text :notes
      t.string :delivered_by_name
      t.date :delivered_by_date
      t.string :received_by_name
      t.date :received_by_date

      t.timestamps
    end
  end
end
