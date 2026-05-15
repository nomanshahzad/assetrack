class CreateAssetItems < ActiveRecord::Migration[8.1]
  def change
    create_table :asset_items do |t|
      t.references :asset, null: false, foreign_key: true
      t.string :item_details
      t.boolean :is_consumable, default: false, null: false
      t.boolean :is_custody, default: false, null: false
      t.integer :quantity
      t.boolean :is_new, default: false, null: false
      t.boolean :is_used, default: false, null: false

      t.timestamps
    end
  end
end
