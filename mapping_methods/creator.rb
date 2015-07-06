require 'rdf'
require 'json'
require 'linkeddata'
module Qa; end
require 'qa/authorities/web_service_base'
require 'qa/authorities/loc'
module MappingMethods
  module Creator 

    def lc_lookup(data)
      authority = Qa::Authorities::Loc.new
      @lc_cache ||= {}
      Array(data.split(';')).each do |creator_name|
        creator_name.strip!
        creator_name.gsub!('"', "")
        next if creator_name.gsub("-","") == ""
        begin
          uri = @lc_cache[creator_name.downcase] || 
            authority.search("#{creator_name}", "names").find{|x| x["label"].strip.downcase == creator_name.downcase} ||
            authority.search("#{creator_name}", "subjects").find{|x| x["label"].strip.downcase == creator_name.downcase} || 
            MappingMethods::Lcsh::name_uri_from_opaquens("#{creator_name}")
        rescue StandardError => e
          puts e
        end
        uri ||= ""
        if !uri.nil? && uri != "" 
#puts "URI: #{uri}"
          parsed_uri = uri["id"].gsub("info:lc", "http://id.loc.gov")
          return parsed_uri
        else
          puts "No URI found for #{creator_name}" unless @lc_cache.include?(creator_name.downcase)
          return creator_name
        end
        @lc_cache[creator_name.downcase] ||= uri
      end
    end


    # Interviewee
    def creator_ive(subject, data)
      data = data.split(";").map(&:strip)
      graph = RDF::Graph.new
      data.each do |name|
        result = lc_lookup(name)
#puts "Result: #{result}"
        if result.include?("http")
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/ive"), RDF::URI(result))
        else
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/ive"), result)
        end
      end
      graph
    end

    # Interviewer
    def creator_ivr(subject, data)
      data = data.split(";").map(&:strip)
      graph = RDF::Graph.new
      data.each do |name|
        result = lc_lookup(name)
#puts "Result: #{result}"
        if result.include?("http")
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/ivr"), RDF::URI(result))
        else
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/ivr"), result)
        end
      end
      graph
    end

    # Transcriber
    def creator_trc(subject, data)
      data = data.split(";").map(&:strip)
      graph = RDF::Graph.new
      data.each do |name|
        result = lc_lookup(name)
#puts "Result: #{result}"
        if result.include?("http")
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/trc"), RDF::URI(result))
        else
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/trc"), result)
        end
      end
      graph
    end

    # Photographer
    def creator_pht(subject, data)
      data = data.split(";").map(&:strip)
      graph = RDF::Graph.new
      data.each do |name|
        result = lc_lookup(name)
#puts "Result: #{result}"
        if result.include?("http")
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/pht"), RDF::URI(result))
        else
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/pht"), result)
        end
      end
      graph
    end

    def gifford_creator(subject, data)
      data = data.split(";").map(&:strip)
      graph = RDF::Graph.new
      data.each do |photographer|
        next unless photographer && photographer != ""
        if photographer.include?("Gifford, Benjamin A.")
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/pht"), RDF::URI("http://id.loc.gov/authorities/names/n92004880"))
        else
          graph << RDF::Statement.new(subject, RDF::URI("http://id.loc.gov/vocabulary/relators/pht"), photographer)
        end
      end
      graph
    end
  end
end
