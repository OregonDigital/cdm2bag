
Dir["./mapping_methods/*.rb"].each { |f| require f }

module MappingMethods
  include MappingMethods::Geographic
  include MappingMethods::Rights
  include MappingMethods::MediaType
end
