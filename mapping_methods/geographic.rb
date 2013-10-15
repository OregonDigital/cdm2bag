module MappingMethods
  module Geographic
    def geocache
      @geocache ||= {}
    end

    def geonames_search(str)
      response = RestClient.get 'http://api.geonames.org/searchJSON', {:params => {:username => 'johnson_tom', :q => str, :maxRows => 1, :style => 'short'}}
      uri = "http://sws.geonames.org/#{JSON.parse(response)['geonames'][0]['geonameId']}"
      geocache[str] = {:uri => RDF::URI(uri)}
    end

    def geographic(subject, data)
      data.slice!('(Ore.)')
      data.slice!(';')
      data.strip!
      unless geocache.include? data
        begin
          geonames_search(data)
        rescue => e
          puts subject, data, e
        end
      end
      if geocache.include? data
        return RDF::Statement.new(subject, RDF::DC[:spatial], geocache[data][:uri])
      else
        return RDF::Statement.new(subject, RDF::DC[:spatial], data)
      end
    end
  end
end
