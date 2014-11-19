
require 'rdf'
require 'rest-client'
require 'json'
require 'rdf/ntriples'
require 'rdf/raptor'

module MappingMethods
  module Geographic
    def geocache
      @geocache ||= {}
    end

    def geonames_search(str, extra_params={})
      str.slice! '(Ore.)'
      str.slice! '(Ore)'
      response = RestClient.get 'http://api.geonames.org/searchJSON', {:params => {:username => 'johnson_tom', :q => str, :maxRows => 1, :style => 'short'}.merge(extra_params)}
      response = JSON.parse(response)
      if response["totalResultsCount"] != 0
        uri = "http://sws.geonames.org/#{response['geonames'][0]['geonameId']}/"
        geocache[str] = {:uri => RDF::URI(uri)}
      else
        geocache[str] = {:uri => str}
      end
    end

    def geographic_oe(subject, data)
      geographic(subject, data, RDF::DC[:spatial], {:adminCode1 => "OR", :countryBias => "US"})
    end

    def ranger_district(subject, data)
      return if data == ""
      graph = RDF::Graph.new
      Array(data.split("/")).each do |district|
        uri = ranger_district_mapping[district]
        graph << RDF::Statement.new(subject, RDF::URI("http://opaquenamespace.org/ns/rangerDistrict"), RDF::URI(uri)) if uri
      end
      graph
    end

    def ranger_district_mapping
      {
        "Waldport" => "http://sws.geonames.org/5758901",
        "Waldpot" => "http://sws.geonames.org/5758901",
        "Alsea" => "http://sws.geonames.org/5711134",
        "ODNRA" => "http://www.geonames.org/5744262",
        "Smith River" => "http://www.geonames.org/5752710",
        "Mapleton" => "http://www.geonames.org/9406413",
        "Hebo?" => "http://www.geonames.org/7310461",
        "Hebo" => "http://www.geonames.org/7310461"
      }
    end

    def gifford_geographic(subject, data)
      graph = RDF::Graph.new
      return graph if data == "" || data.nil?
      Array(data.split(";")).each do |str|
        next if str.to_s.strip == ""
        if str == "Oregon, Central"
          graph << RDF::Statement.new(subject, RDF::DC[:spatial], str)
        else
          graph << geographic(subject, str, RDF::DC[:spatial], {:countryBias => "US", :name_startsWith => str, :orderBy => 'relevance', :adminCode1 => "OR"})
        end
      end
      graph
    end

    def siuslaw_geographic(subject, data)
      graph = RDF::Graph.new
      return graph if data == "" || data.nil?
      Array(data.split("/")).each do |str|
        str = siuslaw_mapping[str] || str
        graph << geographic(subject, str, RDF::DC[:spatial], {:countryBias => "US", :name_startsWith => str, :orderBy => 'relevance'})
      end
      return graph
    end

    def siuslaw_mapping
      {
        "Alsea" => "Alsea Place",
        "ODNRA" => "Oregon Dunes National Recreation Area",
        "Smith River" => "Smith River, Oregon",
        "Mapleton" => "Mapleton, OR",
        "Waldpot" => "Waldport",
        "Hebo?" => "Hebo, OR Place",
        "Hebo" => "Hebo, OR Place"
      }
    end

    def baseball_geographic(subject, data)
      graph = RDF::Graph.new
      data = data.strip
      return graph if data == "" || data.nil?
      str = baseball_mapping[str] || data
      graph << geographic(subject, str)
      return graph
    end

    def baseball_mapping
      {
        "Corvallis (ORE.)" => "Corvallis, OR",
        "Peoria, (Ariz.)" => "Peoria, AZ"
      }
    end

    def streamsurvey_geographic(subject, data)
      graph = RDF::Graph.new
      return graph if data == "" || data.nil?
      Array(data.split(";")).each do |str|
        next if str.to_s.strip == ""
        graph << geographic(subject, str, RDF::DC[:spatial], {:countryBias => "US", :name_startsWith => str, :orderBy => 'relevance'})
      end
      graph
    end

    # def geonames_graph(uri, str)
    #   return @geocache[str][:graph] if @geocache[str].include? :graph
    #   geo_graph = RDF::Graph.load(uri)
    #   graph = RDF::Graph.new

      # q = RDF::Query.new do
      #   pattern [:geoname, RDF::URI('http://www.geonames.org/ontology#name'), :name]
      #   pattern [:geoname, RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#long'), :long]
      #   pattern [:geoname, RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#lat'), :lat]
      #   pattern [:geoname, RDF::URI('http://www.geonames.org/ontology#countryCode'), :countryCode]
      # end

      # q.execute(geo_graph).each do |solution|
      #   graph << RDF::Statement.new(solution[:geoname], RDF::URI('http://www.geonames.org/ontology#name'), solution[:name])
      #   graph << RDF::Statement.new(solution[:geoname], RDF::SKOS.prefLabel, solution[:name])
      #   graph << RDF::Statement.new(solution[:geoname], RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#long'), solution[:long])
      #   graph << RDF::Statement.new(solution[:geoname], RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#lat'), solution[:lat])
      #   graph << RDF::Statement.new(solution[:geoname], RDF::URI('http://www.geonames.org/ontology#countryCode'), solution[:countryCode])
      # end
    #   @geocache[str][:graph] = graph
    # end

    def geographic(subject, data, predicate=RDF::DC[:spatial], extra_params={})
      data.slice!(';')
      data.strip!
      unless geocache.include? data
        begin
          geonames_search(data, extra_params)
        rescue => e
          puts subject, data, e.backtrace
        end
      end
      if geocache.include? data
        graph = RDF::Graph.new
        graph << RDF::Statement.new(subject, predicate, geocache[data][:uri])
        return graph#  << geonames_graph(geocache[data][:uri], data)
      else
        return RDF::Statement.new(subject, predicate, data)
      end
    end
    
    def geopup(subject, data)
      geographic(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/pup"), data)
    end
  end
end
