
Dir["./mapping_methods/*.rb"].each { |f| require f }

module MappingMethods
  include MappingMethods::Geographic
  include MappingMethods::Rights
  include MappingMethods::MediaType
  include MappingMethods::XSDDate
  include MappingMethods::Language
  include MappingMethods::Type
  include MappingMethods::AAT
  include MappingMethods::Replace

  DC_ELEM = RDF::Vocabulary.new('http://purl.org/dc/elements/1.1/')
end
