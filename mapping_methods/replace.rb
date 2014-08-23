require 'rdf'

module MappingMethods
  module Replace
    def replace(subject, data)
      data = "http://oregondigital.org/u?/[collid],#{data}"
      RDF::Graph.new << RDF::Statement.new(subject, RDF::DC.replaces, RDF::URI(data))
    end
  end
end
