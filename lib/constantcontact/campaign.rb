module ConstantContact
  
  class Campaign
    
    def self.get_campaigns(url, connection)
      # initial url, it changes if there is next page
      campaigns_url = url
      campaigns = []
      batch = 0

      begin
        next_batch = false
        res = connection.start_get(campaigns_url)
        puts res
        puts "Parsing this url: #{campaigns_url}"
        doc = Nokogiri::XML(connection.data)
        puts doc

        # check for next link url
        # if it exists, there is a next batch of campaigns
        links = doc.css('link')
        links.each do |link|
          if link['rel'] == 'next'
            campaigns_url = link['href']
            next_batch = true
          end
        end

        # parse campaigns
        xml_campaigns = doc.xpath('//campaign:Campaign', 'campaign' => 'http://ws.constantcontact.com/ns/1.0/')
        puts xml_campaigns
        
        xml_campaigns.each do |entry|
          puts entry

          id = entry.attributes["id"].value.match(/[0-9]+/)
          name = ""
          status = ""
          entry.children.each do |child|
            puts "Child name: " + child.name()
            puts "Child text: " + child.inner_text

            if child.name() == 'Name'
              name = child.inner_text
            elsif child.name() == 'Status'
              status = child.inner_text
            end
          end

          campaign = CampaignStruct.new(id, name, status)
          campaigns << campaign

          id = ''
          name = ''
          status = ''
        end
        batch += 1
      end while next_batch == true

      return campaigns
    end
    
  end
  
end