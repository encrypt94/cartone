module Cartone
  module Services
    class BakecaIt < Service
      def initialize()
        super('bakeca.it', 'http://bologna.bakeca.it', '/offro-casa-0?/search/nope/nope/quartiere-solocitta/inserzionista-privato')
      end
      
      def fetch()
        annunci = []
        page = Nokogiri::HTML(open(self.base_url+self.request))
        page.css("div.annuncio-elenco:nth-child(10) > div.annuncio-item").select do |item|
          annuncio = Annuncio.new
          annuncio.service = self.name
          annuncio.title = item.css("div.annuncio-description > h3 > a").text
          item.css("div.annuncio-description > h3 > a").select do |link|
            annuncio.link = link["href"]
          end
          annuncio.date = Annuncio.parse_date(item.css('div.annuncio-info > p.data').text)
          item.css('div.annuncio-info > p.preferiti').select do |p|
            annuncio.id = self.name+p["id"]
          end
          adv_pg = Nokogiri::HTML(open(annuncio.link))
          annuncio.description = adv_pg.css("div.text:nth-child(6)").text
          adv_pg.css("table.meta > tbody > tr").select do |tr|
            value = tr.css("td").text.chomp.strip
            key = tr.css("th").text.downcase.gsub(':','').chomp.strip
            case key
            when "tipo immobile"
              annuncio.data["type"] = value.chomp
            when "affitto"
              annuncio.data["price"] = value.gsub(/[^0-9,]/,'')
            when "mq"
              annuncio.data["size"] = value.gsub(/[^0-9]/,'')
            end
          end
          adv_pg.css(".gallery > .items > .item > img").select do |img|
            annuncio.images.push(img["src"])
          end
          annunci.push(annuncio)
        end
        return annunci
      end
      
      def next_page()
        if self.request =~ /-casa-([0-9]*)\?\// 
          page_index = $1.to_i+25
          self.request.gsub!(/-casa-([0-9]*)\?\//, "-casa-"+page_index.to_s+"?/")
        end
      end
    end
  end
end
