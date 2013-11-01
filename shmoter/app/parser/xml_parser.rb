require 'xml'
require 'nokogiri'

class XmlParser
  
  class << self
    attr_reader :reader_classes
  end

  @reader_classes = []
  
  def self.read(partner) #Partner have xml_type and xml_url
    reader = reader_for(partner.xml_type, partner.xml_url) #give needful subclass
    return nil unless reader
    reader.read_xml(partner)
  end

  def self.reader_for(type, path)
    reader_class = XmlParser.reader_classes.find do |klass|
      klass.can_read?(type)
    end
    return reader_class.new if reader_class
    nil
  end

  def self.inherited(subclass)
    XmlParser.reader_classes << subclass
  end

  
end

class YandexMarketXml < XmlParser

  def self.can_read?(type)
    type == "YandexMarket"
  end


  def read_xml(partner)#add partner
    #puts filename
    #reader = Nokogiri::XML::Reader(open(filename) )
    xmlfile = Nokogiri::XML(open(partner.xml_url))
    items = xmlfile.xpath("//item")
    # doc = parser.parse
    # doc_hash = {}
    # doc_hash[:root] = doc.root.attributes.to_h
    #doc.root.children.each do |items| 
    items_from_file = {} 
    items.each do |item|
      #if (item.name == "item") and (item.node_type == XML::Reader::TYPE_ELEMENT)

      is_available =  item.attributes["available"].value.to_s
      item_id = item.attributes["id"].value.to_s #id of item from partner
      items_from_file[item_id] = [ partner.id, item_id, is_available]
      #other attributes adding in sub item of xml, example: <lable> T-Shirt</lable> NO ATTRIBUTES!!!
        item.children.each do |ch| 
          if ch.name == "label" 
            items_from_file[item_id]<<ch.text 
          end
        end
           
    end
    #divide for three array: new item, update and available
    items_id_in_db = Item.partner_item.pluck(:partner_item_id)
    items_id_in_file = items_from_file.keys
    no_in_file = items_id_in_db - items_id_in_file #array of id to set unavailable
    new_items = items_id_in_file - items_id_in_db  #array of id no in DB - for insert!!!
    old_item_for_update = items_id_in_file - new_items #array of id in db for update
    #prepare 3 hash
    update_and_available = []
    #no_available = {}
    items_to_insert []
    items_from_file.each do |key, value|
      if (new_items.include?(key))
        items_to_insert.add(value)
      elsif old_item_for_update.include?(key)
        update_and_available.add(value)
      end
    end

    Item.set_unavailable(partner, no_in_file)
    Item.add_new_items(partner, items_to_insert)
    Item.update_items(partner, update_and_available)
        

  end
end


