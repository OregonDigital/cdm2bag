module MappingMethods
  module Collection

    COLLECTION_URIS = {
      :'John H. Gallagher Photography Collection' => RDF::URI('http://oregondigital.org/collections/gallagher'),
      :'Cronk Collection' => RDF::URI('http://oregondigital.org/collections/cronk'),
    }

    def collection(subject, data)
      collection = COLLECTION_URIS[data.to_sym]
      graph = RDF::Graph.new << RDF::Statement.new(subject, RDF::DC.isPartOf, collection)
      graph
    end
  end
end
