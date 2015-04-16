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

#        if type.strip.include? "Autochrome"
#          uri = "http://vocab.getty.edu/aat/300138292"
#        elsif type.strip.include? "Clippings"
#          uri = "http://vocab.getty.edu/aat/300026867"
#		else
          uri = aat_search(filtered_type).first
#		end

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
        "fillms" => "films",
        "mezzotint" => "mezzotints (prints)",
        "relief" => "relief print",
        "intaglio" => "intaglio prints",
        "reproduction" => "reproductions",
        "monotypes" => "monotypes (planographic prints)",
        "aquatint" => "aquatints (prints)",
      }
    end

    def aat_fairbanks(subject, data)
      data = data.gsub(" & ", ";") || data
      data = data.gsub(" and ", ";") || data
      aat_from_search(subject, data)
    end

    def aat_gelatin(subject, data)
      RDF::Graph.new << RDF::Statement.new(subject, RDF.type, RDF::URI('http://vocab.getty.edu/aat/300128695'))
    end

    def aat_siuslaw(subject, data)
      r = RDF::Graph.new
      uri = 'http://vocab.getty.edu/aat/'
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
      uri = 'http://vocab.getty.edu/aat/'
      if data == "B/W" || data == "black and white" || "Black&white" == data || "Black & white" == data
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
      RDF::Graph.new << RDF::Statement.new(subject, RDF.type, RDF::URI('http://vocab.getty.edu/aat/300026430'))
    end

    def aat_streamsurvey(subject, data)
      r = RDF::Graph.new
      uri = 'http://vocab.getty.edu/aat/'
      case data
        when 'Silver gelatin prints'
          uri += '300128695'
        when '4 X 5 Negative', 'Nitrate negatives'
          uri += '300127173'
        else
      end
      r << RDF::Statement.new(subject, RDF.type, RDF::URI(uri))
    end
  end

  # Workaround for frequent net connection errors with Getty sparql endpoint.
  def cached_types
    {
      'Silver gelatin prints' => '300128695',
      'Gelatin silver prints' => '300128695',
      'Postcards' => '300026816',
      'Color Slide' => '300128366',
      'Posters' => '300027221',
      'Halftone print' => '300154372',
      'Signs (Notices)' => '300213259',
      'Magazine covers' => '300215389',
      'Maps' => '300028094',
      'Emblems' => '300123036',
      'Ephemera' => '300028881',
      'Tickets' => '300027381',
      'Periodicals' => '300026657',
      'Envelopes' => '300197601',
      'Stereographs' => '300127197',
      'Photographic prints' => '300127104',
    }
  end

  def aat_gwilliams(subject, data)
    r = RDF::Graph.new
    uri = 'http://vocab.getty.edu/aat/'
    data = data.gsub(';', '') || data
    if cached_types[data].nil?
      puts "Unknown GWilliams Type: #{data}"
    else
      uri += cached_types[data]
    end
    r << RDF::Statement.new(subject, RDF.type, RDF::URI(uri))
  end

end
