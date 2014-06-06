module MappingMethods
  module Premis
    def fixity(subject, data)
      fixity = RDF::Node.new
      graph = RDF::Graph.new << RDF::Statement.new(subject, RDF::URI('http://www.loc.gov/premis/rdf/v1#hasFixity'), fixity)
      graph << RDF::Statement.new(fixity, RDF::URI('http://www.loc.gov/premis/rdf/v1#hasMessageDigest'), data)
    end
  end
end
