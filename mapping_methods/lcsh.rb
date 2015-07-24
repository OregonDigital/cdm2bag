require 'json'
require 'linkeddata'
module Qa; end
require 'qa/authorities/web_service_base'
require 'qa/authorities/loc'
require 'yaml'
require 'pry'
module MappingMethods
  module Lcsh

    def search_from_aat_and_lcname(name)
      authority = Qa::Authorities::Loc.new
      aat_fuzzy_search(name) + authority.search(name, "names")
    end

    def repository_search(name)
      authority = Qa::Authorities::Loc.new
      aat_fuzzy_search(name) + authority.search("#{name} rdftype:CorporateName")
    end

    def lcname(subject, data)
      graph = RDF::Graph.new
      data = data.gsub(/;$/,'')
      if File.exist?("lcname_cache.yml") && !@lcname_matches
        @lcname_matches = YAML.load(File.read("lcname_cache.yml"))
        puts "LOADING #{@lcname_matches.keys.length} ENTRIES FROM NAME CACHE"
      else
        @lcname_matches ||= {}
      end
      if @lcname_matches[data]
        predicate = RDF::DC11.creator
        unless @lcname_matches[data][:uri].kind_of? RDF::URI
          predicate = RDF::DC11.creator
        end
        graph << RDF::Statement.new(subject, predicate, @lcname_matches[data][:uri])
        return graph
      end
      regex = /(?<name>.*) \(.*?(?<birth>[0-9]{3,4})[^0-9]*(?<death>[0-9]{3,4})?.*\)/
      split_data = regex.match(data)
      if split_data && split_data[:name] && split_data[:birth]
        results = search_from_aat_and_lcname(split_data[:name])
        results = results.select do |x|
          x["label"] = x["label"].to_s
          x["id"] = x["id"].to_s
          if split_data[:birth].to_s != ""
            if split_data[:death].to_s != ""
              # If we have both, they have to have both.
              x["label"].include?(split_data[:death].to_s) && x["label"].include?(split_data[:birth])
            else
              # Otherwise, just find birth
              x["label"].include?(split_data[:birth].to_s)
            end
          elsif split_data[:death].to_s != ""
            x["label"].include?(split_data[:death].to_s)
          else
            false
          end
        end
        if results.length != 0
          match = results[0]
          puts "Matching #{match["label"]} to #{data}"
          @lcname_matches[data] = {:uri => RDF::URI(match["id"].gsub("info:lc", "http://id.loc.gov")), :label => match["label"] }
          # graph << RDF::Statement.new(subject, RDF::DC.creator, @lcname_matches[data][:uri])
          # Temporarily all DC11 because reasons.
          graph << RDF::Statement.new(subject, RDF::DC11.creator, @lcname_matches[data][:uri])
        else
          puts "Unable to find definitive match for #{data}"
          @lcname_matches[data] = {:uri => data, :label => data}
          graph << RDF::Statement.new(subject, RDF::DC11.creator, data)
        end
      else
        puts "Unable to extract birth/death from #{data}"
        @lcname_matches[data] = {:uri => data, :label => data}
        graph << RDF::Statement.new(subject, RDF::DC11.creator, data)
      end
      File.open("lcname_cache.yml", 'w') do |f|
        f.write @lcname_matches.to_yaml
      end
      graph
    end

    def lc_repository(subject, data)
      graph = RDF::Graph.new
      data = data.gsub(/;$/,'')
      return graph if data == ""
      if File.exist?("repository_cache.yml") && !@lc_repository_matches
        @lc_repository_matches = YAML.load(File.read("repository_cache.yml"))
        puts "LOADING #{@lc_repository_matches.keys.length} ENTRIES FROM REPOSITORY CACHE"
      else
        @lc_repository_matches ||= {}
      end
      if @lc_repository_matches[data]
        graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/rps"), @lc_repository_matches[data][:uri])
        return graph
      end
      repository_name = data.split(",").first
      results = repository_search(repository_name)
      results.select! do |result|
        result["label"].include?(repository_name) || result["label"].gsub(".", "").include?(repository_name)
      end
      results.select! do |result|
        new_graph = RDF::Graph.new
        result["label"] = result["label"].to_s
        result["id"] = result["id"].to_s
        new_graph.load(result["id"].gsub("info:lc", "http://id.loc.gov"))
        new_graph.query([nil, RDF::SKOS.altLabel, nil]).objects.to_a.select{|x| x.to_s == repository_name}.length > 0 || new_graph.query([nil, RDF::SKOS.prefLabel, nil]).objects.to_a.select{|x| x.to_s == repository_name}.length > 0
      end
      if results.length > 0
        result = results.first
        puts "Repository Match: #{data} is #{result["label"]}"
        @lc_repository_matches[data] = {:uri => RDF::URI(result["id"].gsub("info:lc", "http://id.loc.gov")), :label => result["label"]}
      else
        puts "Missing Repository Match for #{data}"
        @lc_repository_matches[data] = {:uri => data, :label => data}
      end
      File.open("repository_cache.yml", 'w') do |f|
        f.write @lc_repository_matches.to_yaml
      end
      graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/rps"), @lc_repository_matches[data][:uri])
      graph
    end

    def lcsubject(subject, data)
      authority = Qa::Authorities::Loc.new
      graph = RDF::Graph.new
      @lcsubject_cache ||= {}
      Array(data.split(';')).each do |subject_name|
        subject_name.strip!
        subject_name.gsub!('"', "")
        next if subject_name.gsub("-","") == ""
        begin
          uri = @lcsubject_cache[subject_name.downcase] || 
            authority.search("#{subject_name}", "subjects").find{|x| x["label"].strip.downcase == subject_name.downcase} || 
            authority.search("#{subject_name}", "names").find{|x| x["label"].strip.downcase == subject_name.downcase} ||
            authority.search("#{subject_name}", "graphicMaterials").find{|x| x["label"].strip.downcase == subject_name.downcase} ||
            name_uri_from_opaquens("#{subject_name}")
        rescue StandardError => e
          puts e
        end
        uri ||= ""
        if !uri.nil? && uri != "" 

#puts "URI: #{uri}"

          parsed_uri = uri["id"].gsub("info:lc", "http://id.loc.gov")

          graph << RDF::Statement.new(subject, RDF::DC.subject, RDF::URI(parsed_uri))
        else
          puts "No subject heading found for #{subject_name}" unless @lcsubject_cache.include?(subject_name.downcase)
          graph << RDF::Statement.new(subject, RDF::DC.subject, subject_name)

        end
        @lcsubject_cache[subject_name.downcase] ||= uri
      end
      graph
    end


    def name_uri_from_opaquens(data)
      @people ||= RDF::Graph.load("https://raw.githubusercontent.com/OregonDigital/opaque_ns/master/people.jsonld") 
      @creators ||= RDF::Graph.load("https://raw.githubusercontent.com/OregonDigital/opaque_ns/master/creator.jsonld")
      @subjects ||= RDF::Graph.load("https://raw.githubusercontent.com/OregonDigital/opaque_ns/master/subject.jsonld")  

      @graph ||= @people << @creators << @subjects

      @graph_client = SPARQL::Client.new(@graph)

      @name_query_cache ||= {}

#puts "Searching OpaqueNamespace for #{data}"

      query = @name_query_cache[data.downcase] || @graph_client.query("SELECT DISTINCT ?s ?p ?o WHERE { ?s <#{RDF::RDFS.label}> ?o. FILTER(strstarts(lcase(?o), '#{data.downcase}'))}") 

      @name_query_cache[data.downcase] ||= query
      solution = query.first
      if solution

#puts "URI found: #{solution[:s]}"

        result = {"id" => solution[:s].to_s, "label" => data.to_s}
      else
        puts "No OpaqueNamespace name match found for #{data}"
      end
#puts "Result: #{result}"
      result
    end

    def lcsubject_siuslaw(subject, data)
      lcsubject(subject, data.gsub(",",";"))
    end
  end
end
