require 'rdf'

module MappingMethods
  module Creator
    def gifford_creator(subject, data)
      data = data.split(";").map(&:strip)
      graph = RDF::Graph.new
      data.each do |photographer|
        next unless photographer && photographer != ""
        if photographer.include?("Gifford, Benjamin A.")
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/pht"), RDF::URI("http://id.loc.gov/authorities/names/n92004880"))
        else
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/pht"), photographer)
        end
      end
      graph
    end
  end
end
