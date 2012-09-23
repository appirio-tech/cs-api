class AddDescriptionToApiKeys < ActiveRecord::Migration
  def change
    add_column :api_keys, :description, :string
  end
end
