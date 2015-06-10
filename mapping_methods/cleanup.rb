require 'rdf'

module MappingMethods
  module Cleanup
    def baseball_cleanup(collection, graph, subject)
      # Clean up dates.
      dates = graph.query([nil, RDF::DC.date, nil]).group_by{|x| x.object.to_s}
      if dates.keys.length > 1
        remove_dates = dates.select{|key, value| !key.match(/[0-9]{4}-[0-9]{4}/).nil?}
        remove_dates.values.each do |remove_statement|
          remove_statement.each do |statement|
            graph.delete(statement)
          end
        end
      end
      graph
    end

    def lchsa_cleanup(collection, graph, subject)

      # Add the repository field for this collection.
      graph << RDF::Statement.new(subject, RDF::URI.new(@namespaces['marcrel']['rps']), RDF::URI.new('http://id.loc.gov/authorities/names/n77019101'))

      # Add contributingInstitution field for this collection
      graph << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['contributingInstitution']), RDF::URI.new('http://dbpedia.org/resource/Oregon_State_University'))

      # Prepend a label to the lchsaPhotog field and add as a dct:description.
      photog = graph.query([nil, @namespaces['oregon']['lchsaPhotog'], nil])
      graph.delete(photog) # Remove placeholder statement.
      graph << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.description), "Photographer information: #{photog.first.object.to_s}") if photog.first

      # Merges placeholder statements for height, width, and unit into a dct:extent field with format H x W unit.
      height = graph.query([nil, @namespaces['oregon']['lchsaHeight'], nil])
      width = graph.query([nil, @namespaces['oregon']['lchsaWidth'], nil])
      unit = graph.query([nil, @namespaces['oregon']['lchsaUnit'], nil])

      # Remove the placeholder statements.
      graph.delete(height)
      graph.delete(width)
      graph.delete(unit)

      # Only make the dct:extent entry if all of the elements are present.
      if height.first and width.first and unit.first
        dims = "#{width.first.object.to_s.gsub(/[^0-9\.]/,'')} x #{height.first.object.to_s.gsub(/[^0-9\.]/,'')} #{unit.first.object.to_s.downcase}"
        graph << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.extent), dims)
      end

      # Try to make a useful date field out of the value in temporal
      temporal = graph.query([nil, RDF::DC.temporal, nil]).first
      if temporal
        xsd_date = human_to_date(subject, temporal.object.to_s)
        xsd_date.each { |statement| graph << statement }
      end
    end

    def herbarium_cleanup(collection, graph, subject)

      fn = graph.query([subject, @namespaces['oregon']['fileName'], nil])
      # We need to grab the filename from this field before we turn it into an identifier (cpd files won't have one of these).
      if fn.first
        filename = fn.first.object.to_s
        graph.delete(fn)
        graph << RDF::Statement.new(subject, RDF::DC.identifier, filename)
      else
        @log.warn('No fileName')
      end

      full_stmt = graph.query([subject, @namespaces['oregon']['full'], nil])
      full_file = full_stmt.first.object.to_s.downcase
      graph.delete(full_stmt)
      if full_file.end_with? '.cpd'
        # Load the compound object data into the graph.
        graph = load_compound_objects(collection, graph, subject)
      else
        if filename.end_with? '.pdf'
          # The PDFs we have use the filename specified in oregon:fileName, not oregon:full so remove the existing oregon:full name.
          # puts "PDF FILE: #{full_file}"
          graph << RDF::Statement.new(subject, RDF::URI(@namespaces['oregon']['full']), filename)
        else
          # We will store full in case we need the .jpg because the .tif is missing.
          graph << RDF::Statement.new(subject, RDF::URI(@namespaces['oregon']['fullJpg']), full_file)

          # If oregon:full is not a pdf, replace it with the new barcode filename referenced by the accession number.
          accession = graph.query([nil, @namespaces['oregon']['cco/accessionNumber'], nil])
          if accession.first
            barcode = @image_file_map[accession.first.object.to_s] if @image_file_map
            if barcode
              graph << RDF::Statement.new(subject, RDF::URI(@namespaces['oregon']['full']), "#{barcode}.tif")
              graph << RDF::Statement.new(subject, RDF::URI('http://bibframe.org/vocab/barcode'), barcode)
            else
              graph << RDF::Statement.new(subject, RDF::URI(@namespaces['oregon']['full']), filename)
            end
          else
            # If it's an image file, it should have an accession number.
            @log.warn('No accession number found')
          end
        end
      end

      search_params = {}
      # There are some non-US countries/states listed, so see which country we have before running county/state
      country = graph.query([nil, @namespaces['oregon']['herbCountry'], nil])
      search_params[:countryBias] = 'US' if country.first and ('United States' == country.first.object.to_s or 'U.S.A.' == country.first.object.to_s)
      graph << geographic(subject, country.first.object.to_s, RDF::DC[:spatial], search_params) if country.first

      # Run geoname search on state - featureCode ADM1.
      state = graph.query([nil, @namespaces['oregon']['herbState'], nil])
      graph << geographic(subject, state.first.object.to_s, RDF::DC[:spatial], {:featureCode => 'ADM1'}.merge(search_params)) if state.first

      # Combine county and state then run geoname search - county is featureCode ADM2.
      county = graph.query([nil, @namespaces['oregon']['herbCounty'], nil])
      if county.first and state.first and not '[needs research]' == county.first.object.to_s
        combined = "#{county.first.object.to_s} county, #{state.first.object.to_s}"
        stmt = geographic(subject, combined, RDF::DC[:spatial],{:featureCode => 'ADM2'}.merge(search_params))
        graph << stmt if stmt
      end

      # Prepend the abbreviation notes with a label and add to modsrdf:note.
      abbrev = graph.query([nil, @namespaces['oregon']['herbariumAbbrev'], nil])
      graph << RDF::Statement.new(subject, RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1/note'), "Accepted Acronym: #{abbrev.first.object.to_s}" ) if abbrev.first

      # Remove the placeholder statements.
      graph.delete(county)
      graph.delete(state)
      graph.delete(country)
      graph.delete(abbrev)
      # graph.each { |x| puts x.inspect }
      graph
    end

    def gwilliams_cleanup(collection, graph, subject)
      full_stmt = graph.query([subject, @namespaces['oregon']['full'], nil])
      full_file = full_stmt.first.object.to_s.downcase
      graph.delete(full_stmt)
      if full_file.end_with? '.cpd'
        # Load the compound object data into the graph.
        graph = load_compound_objects(collection, graph, subject)
      else
        # We will store full in case we need the .jpg because the .tif is missing.
        graph << RDF::Statement.new(subject, RDF::URI(@namespaces['oregon']['fullJpg']), full_file)

        # The full TIFF filename is in fullTiff
        tiff_stmt = graph.query([subject, @namespaces['oregon']['fullTiff'], nil])
        if tiff_stmt.first.nil?
          @log.warn('No TIFF file found')
        else
          graph << RDF::Statement.new(subject, RDF::URI(@namespaces['oregon']['full']), "#{tiff_stmt.first.object.to_s}")
        end
        graph.delete(tiff_stmt)
      end
      graph
    end

    def streamsurve_cleanup(collection, graph, subject)
      full_stmt = graph.query([subject, @namespaces['oregon']['full'], nil])
      full_file = full_stmt.first.object.to_s.downcase
      graph.delete(full_stmt)
      if full_file.end_with? '.cpd'
        # Load the compound object data into the graph.
        graph = load_compound_objects(collection, graph, subject)
      else
        # We will store full in case we need the .jpg because the .tif is missing.
        graph << RDF::Statement.new(subject, RDF::URI(@namespaces['oregon']['fullJpg']), full_file)
        other_stmt = graph.query([subject, @namespaces['oregon']['otherFile'], nil])
        if other_stmt.first.nil?
          @log.warn('No otherFile found')
        else
          # we will use otherFile for the file name.
          other_file = File.basename(other_stmt.first.object.to_s, '.*')
          graph << RDF::Statement.new(subject, RDF::URI(@namespaces['oregon']['full']), "#{other_file}.tif")
        end
        graph.delete(other_stmt)
      end
      # graph.each {|x| puts x.inspect}
      graph
    end

    def cultural_cleanup(collection, graph, subject)
      full_stmt = graph.query([subject, @namespaces['oregon']['full'], nil])
      full_file = full_stmt.first.object.to_s.downcase
      graph.delete(full_stmt) # This filename isn't saved so we don't need this triple anymore.
      if full_file.end_with? '.cpd'
        # Load the compound object data into the graph.
        graph = load_compound_objects(collection, graph, subject)

        puts "Getting #{full_file}"
      else
        # Do something here if necessary.
      end
      graph
    end

    def human_to_date(subject, human_date)

      # Attempts to convert the plain language formatted date into an ISO8601 formatted dct:date statement.
      # If the date refers to a range then oregon:earliestDate and oregon:latestDate statements are returned.
      statements = []

      if (year = /^(\d{4})$/.match(human_date))
        # Matches a 4-digit year: 1950.
        statements << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.date), year[1]) # YYYY

      elsif (season = /^(circa|ca|summer|winter|fall|spring|early|late)(\.|,)*\s*(\d{4})$/i.match(human_date))
        # Matches Circa/season year: Spring 1930.
        statements << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.date), season[3]) # YYYY

      elsif (year_range = /^(\d{4})'*s$/.match(human_date))
        # Matches a 4-digit year with "s" or "'s": 1940s or 1940's.
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['earliestDate']), "#{year_range[1][0,3]}0") # YYYY
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['latestDate']), "#{year_range[1][0,3]}9") # YYYY

      elsif (year_range = /^(circa|ca|c)\.*\s*(\d{4})'*s$/i.match(human_date))
        # Matches Circa/Ca + "s": Circa 1930s.
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['earliestDate']), "#{year_range[2][0,3]}0") # YYYY
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['latestDate']), "#{year_range[2][0,3]}9") # YYYY

      elsif (year_range = /^(ca|.*)\s*(\d{4})\s*.+\s*(\d{4})$/i.match(human_date))
        # Matches a year range: (Ca) 1960-1961.
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['earliestDate']), "#{year_range[2]}") # YYYY
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['latestDate']), "#{year_range[3]}") # YYYY

      elsif (year_range = /^(ca|.*)\.*\s*(\d{4})\s*-\s*(\d{2})$/i.match(human_date))
        # Matches a year range: (Ca) 1960-61.
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['earliestDate']), "#{year_range[2]}") # YYYY
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['latestDate']), "#{year_range[2][0,2]}#{year_range[3]}") # YYYY

      elsif (year_range = /^(\d{4})\s*-\s*(\d)$/.match(human_date))
        # Matches a year range: 1935-6.
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['earliestDate']), "#{year_range[1]}") # YYYY
        statements << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['latestDate']), "#{year_range[1][0,3]}#{year_range[2]}") # YYYY

      elsif (year_desc = /^(\d{4})\s+(\D*)$/.match(human_date))
        # Matches YEAR ... Description: 1941                                   Newport, OR Bayfront
        statements << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.date), year_desc[1]) # YYYY
        # Special case: since some dates had additional descriptive material, a dct:description field is returned as well.
        statements << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.description), year_desc[2]) # Description

      elsif (mdy = /(\d{2})\/(\d{2})\/(\d{2})/.match(human_date))
        # Matches 05/12/45: 1954-05-12.
        statements << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.date), "19#{mdy[3]}-#{mdy[1]}-#{mdy[2]}") # YYYY-MM-DD

      else
        begin
          # Try letting Date parser do the work and convert it to ISO8601.
          if /\D+(\d+),\s(\d{4})/.match(human_date)
            # Matches: July 4, 1963.
            d = Date.strptime(human_date, '%B %d, %Y')
            statements << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.date),  d.strftime('%Y-%m-%d')) # YYYY-MM

          elsif /(\d+)\s\w+,\s*(\d{4})/.match(human_date)
            # Matches: 31 July, 1963.
            d = Date.strptime(human_date, '%d %B, %Y')
            statements << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.date),  d.strftime('%Y-%m-%d')) # YYYY-MM

          elsif /\w+,\s*\d{4}/.match(human_date)
            # Matches: Month, Year.
            d = Date.strptime(human_date,'%B, %Y')
            statements << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.date),  d.strftime('%Y-%m')) # YYYY-MM

          elsif /\w+\s*\d{4}/.match(human_date)
            # Matches: Month Year.
            d = Date.strptime(human_date,'%B %Y')
            statements << RDF::Statement.new(subject, RDF::URI.new(RDF::DC.date),  d.strftime('%Y-%m')) # YYYY-MM

          end
        rescue ArgumentError
          @log.warn("#{__method__} :: Unable to parse date: #{human_date}")
        end
      end
      # printf("%-20s\n",human_date) # if xsd_dates.count == 0
      # statements.each {|stmt| printf("\t%-45s\t%s\n",stmt.predicate,stmt.object)}
      statements
    end

    def load_compound_objects(collection, graph, subject)
      begin
        # Get the id from 'replaces' object so we can retrieve the .cpd file.
        replaces = graph.query([nil, RDF::DC.replaces, nil])
        cis_id = replaces.first.object.to_s.split("#{collection},").last
        cpd_url = "http://oregondigital.org/cgi-bin/showfile.exe?CISOROOT=/#{collection}&CISOPTR=#{cis_id}&filename=cpdfilename"
        cpd_file = RestClient.get cpd_url
        if 200 == cpd_file.code
          cpd_doc = Nokogiri::XML.parse(cpd_file)
          if cpd_doc.xpath('/cpd/page')
            # Pull out the individual 'page' element(s) from the .cpd and add them to the graph.
            pages = []
            first = nil
            last = nil
            cpd_doc.xpath('/cpd/page').each_with_index do |page, i|
              replaces_uri = RDF::URI.new("http://oregondigital.org/u?/#{collection},#{page.at_xpath('pageptr').text}")
              graph << RDF::Statement.new(subject, RDF::URI.new(@namespaces['oregon']['contents']), replaces_uri)
              cpd_node = RDF::Node.new
              graph << RDF::Statement.new(cpd_node, RDF::URI('http://www.openarchives.org/ore/1.0/datamodel#proxyFor'), replaces_uri)
              first = cpd_node if i == 0
              last = cpd_node
              pages << cpd_node
            end
            # Set the 'first' and 'last' terms for the parent object.
            graph << RDF::Statement.new(subject, RDF::URI('http://www.iana.org/assignments/relation/first'), first) unless first.nil?
            graph << RDF::Statement.new(subject, RDF::URI('http://www.iana.org/assignments/relation/last'), last) unless last.nil?

            # Set the 'next' term for each complex child object.
            pages.each_with_index do |pg, i|
              graph << RDF::Statement.new(pg, RDF::URI('http://www.iana.org/assignments/relation/next'), pages[i+1]) if i+1 < pages.count
            end
            # graph.each { |x| puts x.inspect}
          end
        else
          raise "Unexpected result code received: #{cpd_file.code}"
        end
      rescue => e
        @log.error("Error: #{e} getting RDF file: #{cpd_url}")
      end
      graph
    end

  end
end
