require 'rdf'
require 'rdf/raptor'

module MappingMethods
  module Types
    DCMITYPE_NS = RDF::Vocabulary.new('http://purl.org/dc/dcmitype/')
    DCMITYPES = [:Collection, :Dataset, :Event,
                 :Image, :InteractiveReource, :MovingImage,
                 :PhysicalObject, :Service, :Software,
                 :Sound, :StillImage, :Text
                 ]

    def dcmitype_cache
      @dcmitype_cache ||= {}
    end

    def dcmitype(subject, data)
      data = data.capitalize.to_sym
      return nil unless DCMITYPES.include? data
      return RDF::Graph.new << RDF::Statement.new(subject, RDF::DC.type, DCMITYPE_NS[data])
    end

    def types(subject, data)
      graph = RDF::Graph.new
      data = map_types[data] || data
      data.split(';').each do |part|
        part.strip!
        type = dcmitype(subject, part)
        type ||= RDF::Statement.new(subject, DC_ELEM[:type], RDF::Literal.new(part))
        graph << type
      end
      graph
    end

    def image_type(subject, data)
      RDF::Graph.new << RDF::Statement.new(subject, RDF::DC.type, DCMITYPE_NS[:Image])
    end


    def map_types
      {
        'Moving image' => 'MovingImage'
      }
    end
  end
end
