require 'rdf'
require 'sparql/client'
class Hash
  def stringify_keys
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end
end

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

    def aat_fuzzy_search(str)
      @type_cache ||= {}
      return @type_cache[str] if @type_cache.include?(str)
      sparql = SPARQL::Client.new("http://vocab.getty.edu/sparql")

      q = "select ?id ?label {?id skos:prefLabel|skos:altLabel ?label. FILTER contains(?label,\"#{str}\")}"
      intermediate = sparql.query(q, :content_type => "application/sparql-results+json").map(&:to_h).map(&:stringify_keys)
      result = intermediate.map do |hsh|
        next unless hsh["id"]
        description = RDF::Graph.new.tap{|x| x.load(hsh["id"])}.query([nil, RDF::SCHEMA.description,nil]).objects.to_a.first
        hsh["label"] = "#{hsh["label"]} (#{description})"
        hsh
      end
      @type_cache[str] = result
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
      'Painting' => '300033618',
      'painting' => '300033618',
      'Photography' => '300046300',
      'Drawing' => '300033973',
      'Print' => '300041273',
      'Diagram' => '300015387',
      'Sculpture' => '300047090',
      'Architecture' => '300263552',
      'Documentary Photography' => '300134547',
      'Glasswork' => '300010898',
      'Multimedia works' => '300047910',
      'Assemblages (sculpture)' => '300047194',
      'Collage' => '300033963',
      'Photomontage' => '300134699',
      'Screen print' => '300178688',
      'Installation' => '300182935',
      'Stage Design' => '300054190'
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

  def cached_cultures
    {
      "American" => "http://vocab.getty.edu/aat/300107956",
      "Flemish" => "http://vocab.getty.edu/aat/300111184",
      "Canadian" => "http://vocab.getty.edu/aat/300107962",
      "Swiss" => "http://vocab.getty.edu/aat/300111221",
      "French" => "http://vocab.getty.edu/aat/300111188",
      "German" => "http://vocab.getty.edu/aat/300111192",
      "Greek (ancient)" => "http://vocab.getty.edu/aat/300020072",
      "English" => "http://vocab.getty.edu/aat/300111178",
      "Chilean" => "http://vocab.getty.edu/aat/300107968",
      "Italian" => "http://vocab.getty.edu/aat/300111198"
    }
  end

  def aat_culture(subject, data)
    r = RDF::Graph.new
    data = data.gsub(";", "").strip
    if cached_cultures[data]
      r << RDF::Statement.new(subject, RDF::URI("http://opaquenamespace.org/ns/culturalContext"), RDF::URI(cached_cultures[data]))
    else
      puts "Unable to find URI for culture #{data}"
      r << RDF::Statement.new(subject, RDF::URI("http://opaquenamespace.org/ns/culturalContext"), data)
    end
    r
  end

  def art_material(subject, data)
    r = RDF::Graph.new
    data = data.gsub("; on", " on")
    data = data.gsub(/;$/,'')
    data = data.strip
    r << RDF::Statement.new(subject, RDF::URI("http://opaquenamespace.org/ns/material"), data)
  end

  def aat_art(subject, data)
    r = RDF::Graph.new
    uri = 'http://vocab.getty.edu/aat/'
    data = data.split(";").map(&:strip)
    data.each do |type|
      new_uri = ""
      if cached_types[type].nil?
        puts "Unknown Art Type: #{data}"
        r << RDF::Statement.new(subject, RDF.type, type)
      else
        new_uri = uri + cached_types[type]
        r << RDF::Statement.new(subject, RDF.type, RDF::URI(new_uri))
      end
    end
    r
  end

end
