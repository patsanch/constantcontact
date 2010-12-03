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
      contacts = Contact.get_contacts(@base_url + '/contacts', self)
      return contacts
    end
    
    # STATUS: SENT, DRAFT, RUNNING, SCHEDULED
    def get_campaigns(status = nil)
      url = @base_url + '/campaigns'
      url = status.present? ? url + "?status=#{status}" : url
      campaigns = Campaign.get_campaigns(url, self)
      return campaigns
    end

  end
end