
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

    def geonames_search(str)
      str.slice! '(Ore.)'
      response = RestClient.get 'http://api.geonames.org/searchJSON', {:params => {:username => 'johnson_tom', :q => str, :maxRows => 1, :style => 'short'}}
      uri = "http://sws.geonames.org/#{JSON.parse(response)['geonames'][0]['geonameId']}"
      geocache[str] = {:uri => RDF::URI(uri)}
    end

    def geonames_graph(uri, str)
      return @geocache[str][:graph] if @geocache[str].include? :graph
      geo_graph = RDF::Graph.load(uri)
      graph = RDF::Graph.new

      q = RDF::Query.new do
        pattern [:geoname, RDF::URI('http://www.geonames.org/ontology#name'), :name]
        pattern [:geoname, RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#long'), :long]
        pattern [:geoname, RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#lat'), :lat]
        pattern [:geoname, RDF::URI('http://www.geonames.org/ontology#countryCode'), :countryCode]
      end

      q.execute(geo_graph).each do |solution|
        graph << RDF::Statement.new(solution[:geoname], RDF::URI('http://www.geonames.org/ontology#name'), solution[:name])
        graph << RDF::Statement.new(solution[:geoname], RDF::SKOS.prefLabel, solution[:name])
        graph << RDF::Statement.new(solution[:geoname], RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#long'), solution[:long])
        graph << RDF::Statement.new(solution[:geoname], RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#lat'), solution[:lat])
        graph << RDF::Statement.new(solution[:geoname], RDF::URI('http://www.geonames.org/ontology#countryCode'), solution[:countryCode])
      end
      @geocache[str][:graph] = graph
    end

    def geographic(subject, data, predicate=RDF::DC[:spatial])
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
        graph = RDF::Graph.new
        graph << RDF::Statement.new(subject, predicate, geocache[data][:uri])
        return graph << geonames_graph(geocache[data][:uri], data)
      else
        return RDF::Statement.new(subject, predicate, data)
      end
    end
    
    def geopup(subject, data)
      geographic(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/pup"), data)
    end
  end
end
