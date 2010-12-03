class ContactStruct < Struct.new(:name, :email); end

class CampaignStruct < Struct.new(:id, :name, :status); end

class ListStruct < Struct.new(:name); end