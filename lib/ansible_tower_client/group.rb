module AnsibleTowerClient
  class Group < BaseModel
    extend CollectionMethods

    def self.endpoint
      "groups".freeze
    end

    def children
      self.class.collection_for(Api.get(File.join(self.class.endpoint, id.to_s, "children")))
    end
  end
end
