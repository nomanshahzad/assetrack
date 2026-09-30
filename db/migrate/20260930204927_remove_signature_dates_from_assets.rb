class RemoveSignatureDatesFromAssets < ActiveRecord::Migration[8.1]
  def change
    remove_column :assets, :delivered_by_date, :date
    remove_column :assets, :received_by_date, :date
  end
end
