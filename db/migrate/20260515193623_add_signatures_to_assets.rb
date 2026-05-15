class AddSignaturesToAssets < ActiveRecord::Migration[8.1]
  def change
    add_column :assets, :signature_delivered_by, :text
    add_column :assets, :signature_received_by, :text
  end
end
