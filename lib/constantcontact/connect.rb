require 'net/https'
require 'net/http'
require 'uri'
require 'nokogiri'

module ConstantContact
  
  class Connect
  
    attr_reader :data
    
    API_URL = 'api.constantcontact.com'
  
    def initialize(username, password, key)
      @username = "#{key}%#{username}"
      @password = password
      @base_url = "/ws/customers/#{username}"
    end
  
    def start_get(url)
      req = Net::HTTP.new(API_URL, 443)
      req.use_ssl = true
      req.start do |http|
        req = Net::HTTP::Get.new(url)
        req.basic_auth @username, @password 
        resp, @data = http.request(req)
      end
    end
  
    def start_post(url, xml)
      req = Net::HTTP.new(API_URL, 443)
      req.use_ssl = true
      req.start do |http|
        req = Net::HTTP::Post.new(url)
        req.content_type = 'application/atom+xml'
        req.body = xml
        req.basic_auth @username, @password 
        resp, @data = http.request(req)
      end
    end
  
    def get_contacts
      # initial url, it changes if there is next page
      contacts_url = @base_url + '/contacts'
      contacts = []
      batch = 0

      begin
        next_batch = false
        self.start_get(contacts_url)
        puts "Parsing this url: #{contacts_url}"
        doc = Nokogiri::XML(self.data)
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
            contact = Contact.new(name, email)
            contacts << contact
          end
        end
        batch += 1
      end while next_batch == true
    
      return contacts
    end

  end
end