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

    def baseball_rights(subject, data)
      return if data == "" || !data
      RDF::Graph.new << RDF::Statement(subject, RDF::URI('http://purl.org/dc/terms/rights'), RDF::URI('http://www.europeana.eu/rights/rr-r/'))
    end

    def baseball_rights_owner(subject, data)
      return if data == "" || !data
      graph = RDF::Graph.new
      data = data.split(";")
      Array(data).each do |owner|
        owner.strip!
        if owner.include?("Sports Information")
          graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'Oregon State University Sports Information Office')
          graph << RDF::Statement(subject, RDF::URI('http://id.loc.gov/vocabulary/relators/own'), 'Oregon State University Sports Information Office')
        else
          graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'Special Collections & Archives Research Center, Oregon State University Libraries')
          graph << RDF::Statement(subject, RDF::URI('http://id.loc.gov/vocabulary/relators/own'), 'Special Collections & Archives Research Center, Oregon State University Libraries')
        end
      end
      graph
    end

    def oe_rights(subject, data)
      graph = RDF::Graph.new << RDF::Statement(subject, RDF::URI('http://purl.org/dc/terms/rights'), RDF::URI('http://www.europeana.eu/rights/rr-r/'))
      if data.include? ("OSU Archives")
        graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'OSU Special Collections & Archives Research Center')
      elsif data.include? ("Benton County Historical Museum")
        graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'Benton County Historical Museum')
      end
      graph
    end

    def osu_archive_rights(subject, data)
      graph = RDF::Graph.new << RDF::Statement(subject, RDF::URI('http://purl.org/dc/terms/rights'), RDF::URI('http://www.europeana.eu/rights/rr-r/'))
      graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'OSU Special Collections & Archives Research Center')
      graph
    end

    def rockshore_public_domain(subject, data)
      graph = RDF::Graph.new
      licenses = findCCLicenses(data)

      licenses.each do |license|
        graph << RDF::Statement.new(subject, RDF::URI('http://creativecommons.org/ns#license'), license)
        graph << RDF::Statement.new(subject, RDF::URI('http://purl.org/dc/terms/rights'), license)
      end
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

    def herbarium_rights(subject, data)
      graph = RDF::Graph.new << RDF::Statement(subject, RDF::URI('http://purl.org/dc/terms/rights'), RDF::URI('http://www.europeana.eu/rights/rr-f/'))
      graph << RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/rights/rightsHolder'), 'Oregon State University Herbarium')
      graph << RDF::Statement(subject, RDF::URI('http://data.archiveshub.ac.uk/def/useRestrictions'), data)
      graph
    end

    def streamsurve_rights(subject, data)
      graph << RDF::Statement.new(subject, RDF::DC.rights, RDF::URI('http://www.europeana.eu/rights/rr-f/'))
    end
  end
end
