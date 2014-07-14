module Cartone
  class Annuncio
    
    attr_accessor :id, :service, :link, :title, :description, :images, :data
    
    def initialize()
      self.data = {}
      self.images = []
    end
    
  end
end
