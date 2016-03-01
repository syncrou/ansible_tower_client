module AnsibleTowerClient
  class Inventory < BaseModel
    extend CollectionMethods

    def self.endpoint
      "inventories".freeze
    end
  end
end
