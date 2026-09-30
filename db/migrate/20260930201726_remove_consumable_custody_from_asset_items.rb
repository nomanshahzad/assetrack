class RemoveConsumableCustodyFromAssetItems < ActiveRecord::Migration[8.1]
  def change
    remove_column :asset_items, :is_consumable, :boolean, default: false, null: false
    remove_column :asset_items, :is_custody, :boolean, default: false, null: false
  end
end
