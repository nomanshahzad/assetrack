class ReplaceNewUsedWithConditionOnAssetItems < ActiveRecord::Migration[8.1]
  def up
    add_column :asset_items, :condition, :string

    execute "UPDATE asset_items SET condition = 'new' WHERE is_new = #{quoted_true}"
    execute "UPDATE asset_items SET condition = 'used' WHERE is_used = #{quoted_true}"

    remove_column :asset_items, :is_new
    remove_column :asset_items, :is_used
  end

  def down
    add_column :asset_items, :is_new, :boolean, default: false, null: false
    add_column :asset_items, :is_used, :boolean, default: false, null: false

    execute "UPDATE asset_items SET is_new = #{quoted_true} WHERE condition = 'new'"
    execute "UPDATE asset_items SET is_used = #{quoted_true} WHERE condition = 'used'"

    remove_column :asset_items, :condition
  end
end
