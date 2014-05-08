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
