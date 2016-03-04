module AnsibleTowerClient
  # Base class for JSON wrapper classes. Each Service class should have
  # a corresponding class that wraps the JSON it collects, and each of
  # them should subclass this base class.
  class BaseModel
    # Initially inherit the exclusion list from parent class or create an empty Set.
    def self.excl_list
      @excl_list ||= superclass.respond_to?(:excl_list, true) ? superclass.send(:excl_list) : Set.new
    end

    private_class_method :excl_list

    # Merge the declared exclusive attributes to the existing list.
    def self.attr_hash(*attrs)
      @excl_list = excl_list | Set.new(attrs.map(&:to_s))
    end

    private_class_method :attr_hash

    # Constructs and returns a new JSON wrapper class. Pass in a plain
    # JSON string and it will automatically give you accessor methods
    # that make it behave like a typical Ruby object. You may also pass
    # in a hash.
    #
    # Example:
    #   class Person < AnsibleTowerClient::BaseModel; end
    #
    #   json_string = '{"firstname":"jeff", "lastname":"durand",
    #     "address": { "street":"22 charlotte rd", "zipcode":"01013"}
    #   }'
    #
    #   # Or whatever your subclass happens to be.
    #   person = Person.new(json_string)
    #
    #   # The JSON properties are now available as methods.
    #   person.firstname        # => 'jeff'
    #   person.address.zipcode  # => '01013'
    #
    #   # Or you can get back the original JSON if necessary.
    #   person.to_json # => Returns original JSON
    #
    def initialize(json = {})
      # Find the exclusion list for the model of next level (@embed_model)
      # '#' is the separator between levels. Remove attributes
      # before the first separator.
      child_excl_list = self.class.send(:excl_list).map do |e|
        e.index('#') ? e[e.index('#') + 1..-1] : ''
      end
      @embed_model = Class.new(BaseModel) do
        attr_hash(*child_excl_list)
      end

      __setobj__(json.kind_of?(Hash)? json.dup : JSON.parse(json))
    end

    def to_h
      __getobj__.dup
    end

    def to_hash
      __getobj__.dup
    end

    def to_json
      __getobj__.to_json
    end

    def to_s
      __getobj__.to_json
    end

    def inspect
      string = "<#{self.class} "
      method_list = methods(false).select { |m| !m.to_s.include?('=') }
      string << method_list.map { |m| "#{m}=#{send(m).inspect}" }.join(", ")
      string << ">"
    end

    def ==(other)
      return false unless other.kind_of?(BaseModel)
      __getobj__ == other.__getobj__
    end

    def eql?(other)
      return false unless other.kind_of?(BaseModel)
      __getobj__.eql?(other.__getobj__)
    end

    # Support hash style accessors
    def [](key)
      __getobj__[key]
    end

    def []=(key, val)
      key_exists = __getobj__.include?(key)
      __getobj__[key] = val

      return if key_exists
      add_accessor_methods(snake_case(key), key)
    end

    protected

    def __getobj__
      @hashobj
    end

    # Create snake_case accessor methods for all hash attributes
    # Use _alias if an accessor conflicts with existing methods
    def __setobj__(obj)
      @hashobj = obj
      excl_list = self.class.send(:excl_list)
      obj.each do |key, value|
        snake = snake_case(key)
        unless excl_list.include?(snake) # Must deal with nested models
          if value.kind_of?(Array)
            newval = value.map { |elem| elem.kind_of?(Hash) ? @embed_model.new(elem) : elem }
            obj[key] = newval
          elsif value.kind_of?(Hash)
            obj[key] = @embed_model.new(value)
          end
        end

        add_accessor_methods(snake, key)
      end
    end

    def add_accessor_methods(method, key)
      method.prepend('_') if methods.include?(method.to_sym)
      instance_eval { define_singleton_method(method) { __getobj__[key] } }
      instance_eval { define_singleton_method("#{method}=") { |val| __getobj__[key] = val } }
    end

    def snake_case(name)
      name.to_s.gsub(/(.)([A-Z])/, '\1_\2').downcase
    end
  end
end
