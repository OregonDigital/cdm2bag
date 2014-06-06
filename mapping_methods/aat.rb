require 'rdf'
require 'sparql/client'

module MappingMethods
  module AAT

    def aat_search(str)
      sparql = SPARQL::Client.new("http://vocab.getty.edu/sparql")

      q = """SELECT * {
        ?concept skosxl:prefLabel|skosxl:altLabel [ gvp:term ?term ].
        FILTER(str(?term) = '#{str}')
      }"""
      result = sparql.query q
      
    end

    def aat_gelatin(subject, data)
      RDF::Graph.new << RDF::Statement.new(subject, RDF.type, RDF::URI('http://vocab.getty.edu/aat/300128695'))
    end

    def aat_sheetmusic(subject, data)
      RDF::Graph.new << RDF::Statement.new(subject, RDF.type, RDF::URI('http://vocab.getty.edu/resource/aat/300026430'))
    end
    
  end
end
