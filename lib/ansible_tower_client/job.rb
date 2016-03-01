module AnsibleTowerClient
  class Job < BaseModel
    extend CollectionMethods

    def self.endpoint
      "jobs".freeze
    end
  end
end

