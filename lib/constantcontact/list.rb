module ConstantContact
  
  class List
    
    def self.get_lists(url, connection)
      # initial url, it changes if there is next page
      lists_url = url
      lists = []
      batch = 0

      begin
        next_batch = false
        res = connection.start_get(lists_url)
        puts res
        puts "Parsing this url: #{lists_url}"
        doc = Nokogiri::XML(connection.data)
        puts doc

        # check for next link url
        # if it exists, there is a next batch of lists
        links = doc.css('link')
        links.each do |link|
          if link['rel'] == 'next'
            lists_url = link['href']
            next_batch = true
          end
        end

        # parse lists
        xml_lists = doc.xpath('//contactlist:ContactList', 'contactlist' => 'http://ws.constantcontact.com/ns/1.0/')
        puts xml_lists
        
        xml_lists.each do |entry|
          puts entry
          
          name = ""
          email = ""
          entry.children.each do |child|
            puts "Child name: " + child.name()
            puts "Child text: " + child.inner_text

            if child.name() == 'Name'
              puts "Add to list"
              
              name = child.inner_text
              list = ListStruct.new(name)
              lists << list
            end
          end

        end
        batch += 1
      end while next_batch == true

      return lists
    end
  
  end
  
end