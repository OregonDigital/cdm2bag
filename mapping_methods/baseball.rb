module MappingMethods
  module Baseball
    def baseball_homeaw(subject, data)
      return if data == ""
      RDF::Graph.new << RDF::Statement.new(subject, RDF::URI("http://purl.org/dc/terms/description"), "#{data} Game")
    end

    def baseball_description(subject, data)
      data = data.gsub("<br>"," ") || data
      RDF::Graph.new << RDF::Statement.new(subject, RDF::URI("http://purl.org/dc/terms/description"), data)
    end
  end
end
