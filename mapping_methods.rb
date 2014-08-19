
Dir["./mapping_methods/*.rb"].each { |f| require f }

module MappingMethods
  include MappingMethods::Geographic
  include MappingMethods::Rights
  include MappingMethods::MediaType
  include MappingMethods::XSDDate
  include MappingMethods::Language
  include MappingMethods::Types
  include MappingMethods::Premis
  include MappingMethods::AAT
  include MappingMethods::Collection
  include MappingMethods::Replace
  include MappingMethods::Ethnographic
  include MappingMethods::Lcsh

  DC_ELEM = RDF::Vocabulary.new('http://purl.org/dc/elements/1.1/')
end
