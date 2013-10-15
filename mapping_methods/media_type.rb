require 'rdf'

module MappingMethods
  module MediaType
    def mime(subject, data)
      graph = RDF::Graph.new
      mimetype = /[a-z]+\/[a-z]+/.match(data)
      if mimetype
        graph << RDF::Statement.new(subject, RDF::URI('http://purl.org/dc/terms/format'), RDF::URI("http://purl.org/NET/mediatypes/#{mimetype[0]}"))
        graph << RDF::Statement.new(RDF::URI("http://purl.org/NET/mediatypes/#{mimetype[0]}"), RDF::RDFS[:label], RDF::Literal(mimetype[0]))
      else
        graph << RDF::Statement.new(subject, RDF::URI('http://purl.org/dc/terms/format'), RDF::Literal(data))
      end
      graph
    end
  end
end
