class Item < ActiveRecord::Base
  belongs_to :partner
  validates_uniqueness_of :partner_item_id, :scope => :partner_id

  def self.mass_insert #(data_arr)
    inserts = []
    data_arr = [[2, true, "1188", "sss"], [2, true, "1189", "sss"], [2, true, "1190", "sss"]] 
    #time = Time.now.to_s(:db)
    data_arr.each do |item|
      inserts.push "(#{item[0]}, '#{item[1]}', '#{item[2]}', '#{item[3]}')"
    end
    sql = "INSERT INTO items (partner_id, avalible_in_store, partner_item_id, title) VALUES #{inserts.join(", ")}"
    ActiveRecord::Base.connection.execute(sql) 
  end
end
