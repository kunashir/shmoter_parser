class Item < ActiveRecord::Base
  belongs_to :partner
  validates_uniqueness_of :partner_item_id, :scope => :partner_id

  scope :partner_item, ->(pr) {where(partner_id: pr)}

  def self.mass_insert (data_arr)
    inserts = []
    #ata_arr = [[2, true, "1188", "sss"], [2, true, "1189", "sss"], [2, true, "1190", "sss"]] 
    #time = Time.now.to_s(:db)
    data_arr.each do |item|
      inserts.push "(#{item[0]}, '#{item[1]}', '#{item[2]}', '#{item[3]}')"
    end
    sql = "INSERT INTO items (partner_id, avalible_in_store, partner_item_id, title) VALUES #{inserts.join(", ")}"
    ActiveRecord::Base.connection.execute(sql) 
  end

  def self.set_unavailable(pr, arr)
    Item.partner_item(pr).where( partner_item_id:  arr).update_all(avalible_in_store: false)
  end

  def self.add_new_items(partner, items_to_insert)
    Item.mass_insert(items_to_insert)
  end

  def self.update_items(pr, items_arr)
    items_arr.each do |item|
      Item.sql_update(item)
    end
  end

  def self.sql_update(attr_arr)
    sql = "UPDATE items SET  avalible_in_store=#{attr_arr[1]}, title=#{attr_arr{3}} WHERE (partner_id = #{attr_arr[0]} 
      and partner_item_id = #{attr_arr[2]})}"
    ActiveRecord::Base.connection.execute(sql)
  end
end
