module Cartone
  module Services
    class AffittoIt < Service
      def initialize()
        super('affitto.it', 'http://www.affitto.it','/elenco.php?comune=Bologna+%28BO%29&comune_ID=&tipologia=appartamento&locali_min=&locali_max=&prezzo_min=&prezzo_max=&mq_min=&mq_max=&codice_tipo_utente=privato&testo=&codice_tipo_annuncio=OI&nazione=IT&id_comune=&SearchButton=CERCA')
      end

      def fetch()
        annunci = []
        page = Nokogiri::HTML(open(self.base_url+self.request))
        page.css('table.risultati').select do |table|
          annuncio = Annuncio.new
          annuncio.service = self.name
          annuncio.title = table.css('span.colorem').text
          table.css('a.link_hover_dettaglio').select do |link|
            annuncio.link = link["href"]
            if(annuncio.link =~ /id_annuncio=([0-9]*)/)
              annuncio.id = self.name+$1
            else
              next
            end
            annuncio.data["price"] = table.css('li.liprezzo').text.gsub(/[^0-9]/,'')
            annuncio.data["type"] = table.css('ul.dettagli_top > li:nth-child(2)').text
            annuncio.data["size"] = table.css('ul.dettagli_top > li:nth-child(3)').text.gsub(/[^0-9]/,'')
          end
          adv_pg = Nokogiri::HTML(open(annuncio.link))
          annuncio.description = adv_pg.css("#annuncio_descrizione > #desc_corpo > h2.desc_dettaglio").text
          ['#ads_sx', '#ads_dx'].each do |column|
            adv_pg.css(column).inner_html.strip.split("<br>").each do |info|
              if info =~ /<strong>(.*):<\/strong>(.*)/
                key = $1.downcase
                value = $2.strip
                case key
                when 'ultimo aggiornamento'
                  annuncio.date = Annuncio.parse_date(value)
                when 'num. camere da letto'
                  annuncio.data["camere"] = value
                end
              end
            end
          end
          adv_pg.css('#anteprime > a > img').select do |img|
            annuncio.images.push(self.base_url+img["src"])
          end
          annunci.push(annuncio)
        end
        return annunci
      end

      def next_page()
        if self.request =~ /pg=([0-9]*)/
          page_index = $1.to_i+1
          self.request.gsub!("pg="+$1,"pg="+page_index.to_s)
        else
          self.request = self.request+"&pg=2"
        end
      end
    end
  end
end
