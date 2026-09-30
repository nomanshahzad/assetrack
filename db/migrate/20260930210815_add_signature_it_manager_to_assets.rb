class AddSignatureItManagerToAssets < ActiveRecord::Migration[8.1]
  def change
    add_column :assets, :signature_it_manager, :text
  end
end
