require 'json'
require 'linkeddata'
module Qa; end
require 'qa/authorities/web_service_base'
require 'qa/authorities/loc'
module MappingMethods
  module Lcsh

    def lcname(subject, data)
      authority = Qa::Authorities::Loc.new
      graph = RDF::Graph.new
      @lcname_matches ||= {}
      if @lcname_matches[data]
        graph << RDF::Statement.new(subject, RDF::DC.creator, @lcname_matches[data])
        return graph
      end
      regex = /(?<name>.*) \(.*?(?<birth>[0-9]{4}).*(?<death>[0-9]{4})?.*\)/
      split_data = regex.match(data)
      if split_data && split_data[:name] && split_data[:birth]
        results = authority.search(split_data[:name], "names")
        results = results.select do |x|
          (split_data[:birth].to_s != "" && x["label"].include?(split_data[:birth].to_s)) || (split_data[:death].to_s != "" && x["label"].include?(split_data[:death].to_s))
        end
        if results.length != 0
          match = results[0]
          puts "Matching #{match["label"]} to #{data}"
          @lcname_matches[data] = RDF::URI(match["id"].gsub("info:lc", "http://id.loc.gov"))
          graph << RDF::Statement.new(subject, RDF::DC.creator, @lcname_matches[data])
        else
          puts "Unable to find definitive match for #{data}"
          @lcname_matches[data] = data
          graph << RDF::Statement.new(subject, RDF::DC11.creator, data)
        end
      else
        puts "Unable to extract birth/death from #{data}"
        @lcname_matches[data] = data
        graph << RDF::Statement.new(subject, RDF::DC11.creator, data)
      end
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
