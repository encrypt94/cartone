module Cartone
  class Service
    attr_accessor :base_url, :name, :request

    def initialize(name, base_url, request)
      self.name = name
      self.base_url = base_url
      self.request = request
    end

    def fetch()
      raise NoMethodError.new("#{self.name} needs to implement fetch()!")
    end

    def next_page()
      raise NoMethodError.new("#{self.name} needs to implement next_page()!")
    end

    def is_alive(link)
      raise NoMethodError.new("#{self.name} needs to implement is_alive()!")
    end
  end
end
