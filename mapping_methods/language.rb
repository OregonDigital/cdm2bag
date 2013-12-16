require 'rdf'
require 'rdf/ntriples'
require 'iso-639'

module MappingMethods
  module Language
    def language_cache
      @language_cache ||= {}
    end

    def iso_language(subject, data)
      graph = RDF::Graph.new
      data.split(';').each do |lang|
        iso_lang = ISO_639.find(lang.strip)

        if iso_lang
          unless language_cache.include? iso_lang.first
            language_cache[iso_lang.first] = RDF::Graph.load("http://id.loc.gov/vocabulary/iso639-1/#{iso_lang[2]}.nt") unless iso_lang[2].empty?
            language_cache[iso_lang.first] ||= RDF::Graph.load("http://id.loc.gov/vocabulary/iso639-2/#{iso_lang[0]}.nt")
            language_cache[iso_lang.first] ||= RDF::Graph.load("http://id.loc.gov/vocabulary/languages/#{iso_lang[0]}.nt")
          end
          lang_uri = language_cache[iso_lang.first].subjects.first
          q = RDF::Query.new do
            pattern [lang_uri, RDF.type, RDF::URI('http://www.loc.gov/mads/rdf/v1#Language')]
            pattern [:lang, RDF::SKOS.prefLabel, :prefLabel]
          end

          q.execute(language_cache[iso_lang.first]).each do |solution|
            if solution[:prefLabel].language == :en
              graph << RDF::Statement.new(solution[:lang], RDF::SKOS.prefLabel, solution[:prefLabel])
              graph << RDF::Statement.new(subject, RDF::DC.language, solution[:lang])
            end
          end
        else
          graph << RDF::Statement.new(subject, RDF::URI.new('http://purl.org/dc/elements/1.1/language'), RDF::Literal.new(data))
        end
      end
      graph
    end

  end
end
