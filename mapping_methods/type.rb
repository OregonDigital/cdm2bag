require 'rdf'
require 'rdf/raptor'

module MappingMethods
  module Type
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
      graph = RDF::Graph.new
      graph << RDF::Statement.new(subject, RDF::DC.type, DCMITYPE_NS[data])
      unless dcmitype_cache.include? data
        type_graph = RDF::Graph.load(DCMITYPE_NS[data])
        q = RDF::Query.new do
          pattern [DCMITYPE_NS[data], RDF::RDFS.label, :label]
          pattern [DCMITYPE_NS[data], RDF.type, :type]
        end
        q.execute(type_graph).each do |solution|
          dcmitype_cache[data] = RDF::Graph.new
          dcmitype_cache[data] << RDF::Statement.new(DCMITYPE_NS[data], RDF::RDFS.label, solution[:label])
          dcmitype_cache[data] << RDF::Statement.new(DCMITYPE_NS[data], RDF.type, solution[:type])
        end
      end
      graph << dcmitype_cache[data]
    end

    def type(subject, data)
      graph = RDF::Graph.new
      data.split(';').each do |part|
        part.strip!
        type = dcmitype(subject, part)
        type ||= RDF::Statement.new(subject, DC_ELEM[:type], RDF::Literal.new(part))
        graph << type
      end
      graph
    end
  end
end
