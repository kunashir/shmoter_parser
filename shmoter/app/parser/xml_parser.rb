class XmlParser
  
  class << self
    attr_reader :reader_classes
  end

  @reader_classes = []
  
  def self.read(Partner) #Partner have xml_type and xml_url
    reader = reader_for(Partner.xml_type, Partner.xml_url) #give needful subclass
    return nil unless reader
    reader.read(type)
  end

  def self.reader_for(type, path)
    reader_class = XmlParser.reader_classes.find do |klass|
      klass.can_read?(type)
    end
    return reader_class.new(path) if reader_class
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


  def read_xml(filename)
    parser = XML::Parser.file(filename.to_s)
    doc = parser.parse
    doc_hash = {}
    doc_hash[:root] = doc.root.attributes.to_h
    doc.root.children.each do |items| 
      #puts table_part.name
      #array_of_table_part = Array.new
      items.children.each do |item|
        
        attrs = str.attributes.to_h # id and available
        if attrs["available"].to_b #Item is available
          db_item = Item.find_by( partner_item_id: attrs["id"]) || Item.new 
          item.children.each do |item_attr|
            db_item[item_attr.name] = item_attr.value
          end
        end
      end
     
    end
   
  end
end


