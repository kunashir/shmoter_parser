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
      #end
      #end
      #array_of_table_part = Array.new
      # items.children.each do |item|
        
      #   attrs = str.attributes.to_h # id and available
      #   if attrs["available"].to_b #Item is available
      #     db_item = Item.find_by( partner_item_id: attrs["id"]) || Item.new 
      #     item.children.each do |item_attr|
      #       db_item[item_attr.name] = item_attr.value
      #     end
      #   end
      #end
     
    end
    puts items_from_file 
  end
end


