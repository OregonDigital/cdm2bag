require 'rdf'
require 'sparql/client'

module MappingMethods
  module AAT

    def aat_search(str)
      str = str.downcase
      @type_cache ||= {}
      return @type_cache[str] if @type_cache.include?(str)
      sparql = SPARQL::Client.new("http://vocab.getty.edu/sparql")

      q = "select distinct ?subj {?subj skos:prefLabel|skos:altLabel ?label. filter(str(?label)=\"#{str}\")}"
      @type_cache[str] = sparql.query(q, :content_type => "application/sparql-results+json")
    end

    def aat_from_search(subject, data)
      r = RDF::Graph.new
      data = data.split(";")
      Array(data).each do |type|
        filtered_type = type.downcase.strip.gsub("film ","")
        filtered_type = type_match[filtered_type] if type_match.include?(filtered_type)
        uri = aat_search(filtered_type).first
        unless uri
          r << RDF::Statement.new(subject, RDF.type, type)
          puts "No result for #{type}"
          next
        end
        uri = uri.to_hash[:subj] if uri
        r << RDF::Statement.new(subject, RDF.type, uri)
      end
      r
    end

    def type_match
      {
        "slides" => "slides (photographs)",
        "negatives" => "negatives (photographic)",
        "book illustrations" => "illustrations (layout features)",
        "programs" => "programs (documents)",
        "letters" => "letters (correspondence)",
        "cyanotypes" => "cyanotypes (photographic prints)",
        "fillms" => "films"
      }
    end

    def aat_gelatin(subject, data)
      RDF::Graph.new << RDF::Statement.new(subject, RDF.type, RDF::URI('http://vocab.getty.edu/aat/300128695'))
    end

    def aat_siuslaw(subject, data)
      r = RDF::Graph.new
      uri = 'http://vocab.getty.edu/resource/aat/'
      if data.start_with?("Slide")
        uri += "300128371"
      elsif data == "Photograph"
        uri += "300046300"
      elsif data == "Negative"
        uri += "300128695"
      elsif data == "Cartoon"
        uri += "300123430"
      end
      r << RDF::Statement.new(subject, RDF.type, RDF::URI(uri))
    end

    def aat_siuslaw_colorcontent(subject, data)
      r = RDF::Graph.new
      uri = 'http://vocab.getty.edu/resource/aat/'
      if data == "B/W" || data == "black and white"
        uri += "300265434"
      elsif data == "Color"
        uri += "300056130"
      elsif data == "RGB"
        uri += "300266239"
      else
        raise "Unknown siuslaw color sent: #{data}"
      end
      r << RDF::Statement.new(subject, RDF::URI.new("http://bibframe.org/vocab-list/#colorContent"), RDF::URI.new(uri))
    end

    def aat_sheetmusic(subject, data)
      RDF::Graph.new << RDF::Statement.new(subject, RDF.type, RDF::URI('http://vocab.getty.edu/resource/aat/300026430'))
    end
    
  end
end
