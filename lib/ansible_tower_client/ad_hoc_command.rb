module AnsibleTowerClient
  class AdHocCommand < BaseModel
    extend CollectionMethods

    def relaunch
      Api.post("#{url}relaunch/")
    end

    def self.endpoint
      "ad_hoc_commands".freeze
    end
  end
end

