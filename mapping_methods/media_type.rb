require 'rdf'
require 'mime/types'

module MappingMethods
  module MediaType
    def mime(subject, data)
      graph = RDF::Graph.new
      return graph if data.empty?
      mimetype = MIME::Types[data]
      if mimetype
        graph << RDF::Statement.new(subject, RDF::URI('http://purl.org/dc/terms/format'), RDF::URI("http://purl.org/NET/mediatypes/#{mimetype.first}"))
        graph << RDF::Statement.new(RDF::URI("http://purl.org/NET/mediatypes/#{mimetype.first}"), RDF::RDFS[:label], RDF::Literal(mimetype.first))
      else
        graph << RDF::Statement.new(subject, RDF::URI('http://purl.org/dc/terms/format'), RDF::Literal(data))
      end
      graph
    end
  end
end
