module AnsibleTowerClient
  class JobTemplate < BaseModel
    extend CollectionMethods

    def launch(vars = {})
      launch_url = "#{url}launch/"
      extra = JSONValues.new(vars).extra_vars
      resp = Api.post(launch_url, extra).body
      job = JSON.parse(resp)
      Job.find(job['job'])
    end

    def self.endpoint
      "job_templates".freeze
    end
  end
end

