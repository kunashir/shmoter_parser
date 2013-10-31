class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :partner_id
      t.boolean :avalible_in_store
      t.string :partner_item_id
      t.string :title

      t.timestamps
    end

    add_index :items, ["partner_id", "partner_item_id"], unique: true
  end
end
