require 'rdf'
require 'rdf/ntriples'

module MappingMethods
  module Ethnographic
    def ethnographic(subject, data)
      RDF::Statement(subject, RDF::URI('http://opaquenamespace.org/ns/ethnot'), slug(data))
    end

    def slug(str)
      str.downcase.split.each_with_index.map { |v,i|  i == 0 ? v : v.capitalize }.join.gsub(/[^a-zA-Z]/, '').to_sym
    end
  end
end
