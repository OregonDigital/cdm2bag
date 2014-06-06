require 'rdf'

module MappingMethods
  module Rights
    CCLICENSES =
      [
       { :alt => "CC by-nc-nd 3.0 US",
         :uri => RDF::URI("http://creativecommons.org/licenses/by-nc-nd/3.0/us"),
         :name => "Creative Commons Attribution-Noncommercial-No Derivative Works 3.0 United States License" },
      ]

    def findCCLicenses(data)
      licenses = []
      CCLICENSES.each do |license|
        licenses << license[:uri] if data.include? license[:uri]
      end
      licenses << RDF::URI("http://creativecommons.org/publicdomain/mark/1.0/") if data.downcase.include? 'public domain'
      licenses
    end
    
    def generateRights(data)
    end

    def folkrights(subject, data)
      graph = RDF::Graph.new << RDF::Statement(subject, RDF::URI('http://purl.org/dc/terms/rights'), RDF::URI('http://opaquenamespace.org/rights/educational'))
      graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'Oregon Arts Commission') if data.include 'Oregon Arts Commission'
      graph
    end

    def siuslaw_rights(subject, data)
      graph = RDF::Graph.new << RDF::Statement(subject, RDF::URI('http://purl.org/dc/terms/rights'), RDF::URI('http://www.europeana.eu/rights/rr-r/'))
      if data.include? 'Siuslaw National Forest'
        graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'Siuslaw National Forest')
      elsif data.include? 'Cronk'
        graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'Cronk Family')
      end
      graph
    end

    def osu_archive_rights(subject, data)
      graph = RDF::Graph.new << RDF::Statement(subject, RDF::URI('http://purl.org/dc/terms/rights'), RDF::URI('http://www.europeana.eu/rights/rr-r/'))
      graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'OSU Archives')
      graph
    end

    def rights(subject, data)
      graph = RDF::Graph.new
      licenses = findCCLicenses(data)

      licenses.each do |license|
        graph << RDF::Statement.new(subject, RDF::URI('http://creativecommons.org/ns#license'), license)
      end

      graph << RDF::Statement.new(subject, RDF::URI('http://purl.org/dc/elements/1.1/rights'), data)
      graph
    end
  end
end
