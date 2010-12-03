module ConstantContact
  
  class Contact
    
    def self.get_contacts(url, connection)
      # initial url, it changes if there is next page
      contacts_url = url
      contacts = []
      batch = 0

      begin
        next_batch = false
        res = connection.start_get(contacts_url)
        puts res
        puts "Parsing this url: #{contacts_url}"
        doc = Nokogiri::XML(connection.data)
        puts doc

        # check for next link url
        # if it exists, there is a next batch of contacts
        links = doc.css('link')
        links.each do |link|
          if link['rel'] == 'next'
            contacts_url = link['href']
            next_batch = true
          end
        end

        # parse contacts
        xml_contacts = doc.xpath('//contact:Contact', 'contact' => 'http://ws.constantcontact.com/ns/1.0/')
        puts xml_contacts
        
        xml_contacts.each do |entry|
          puts entry
          
          name = ""
          email = ""
          entry.children.each do |child|
            puts "Child name: " + child.name()
            puts "Child text: " + child.inner_text

            if child.name() == 'Name'
              name = child.inner_text
            elsif child.name() == 'EmailAddress'
              email = child.inner_text
            end
          end

          if email.present?
            contact = ContactStruct.new(name, email)
            contacts << contact
          end
        end
        batch += 1
      end while next_batch == true

      return contacts
    end
  
  end
  
end