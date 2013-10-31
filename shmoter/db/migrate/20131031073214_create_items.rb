class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :partner_id
      t.boolean :avalible_in_store
      t.string :partner_item_id
      t.string :title

      t.timestamps
    end
  end
end
