module Cartone
  class Annuncio
    
    attr_accessor :id, :date, :service, :link, :title, :description, :images, :data
    
    def initialize()
      self.data = {}
      self.images = []
    end

    def self.parse_date(text)
      text = text.to_s.downcase
      text.gsub!(/ieri/,'yesterday ')
      text.gsub!(/oggi/,'today ')
      text.gsub!(/gen(naio)?/,'january')
      text.gsub!(/feb(braio)?/,'february')
      text.gsub!(/mar(zo)?/,'march')
      text.gsub!(/apr(ile)?/,'april')
      text.gsub!(/mag(gio)?/,'may')
      text.gsub!(/giu(gno)?/,'june')
      text.gsub!(/lug(lio)?/,'july')
      text.gsub!(/ago(sto)?/,'august')
      text.gsub!(/set(tembre)?/,'september')
      text.gsub!(/ott(obre)?/,'october')  
      text.gsub!(/nov(embre)?/,'november')
      text.gsub!(/dic(embre)?/,'december')
      return Chronic.parse(text)
    end   
  end
end
