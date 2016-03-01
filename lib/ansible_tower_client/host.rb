module AnsibleTowerClient
  class Host < BaseModel
    extend CollectionMethods

    def self.endpoint
      "hosts".freeze
    end

    def groups
      self.class.collection_for(Api.get(File.join(self.class.endpoint, id.to_s, "groups")))
    end
  end
end
