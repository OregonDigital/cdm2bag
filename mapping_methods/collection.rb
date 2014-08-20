module MappingMethods
  module Collection

    COLLECTION_URIS = {
      :'John H. Gallagher Photography Collection' => RDF::URI('http://oregondigital.org/collections/gallagher'),
      :'Cronk Collection' => RDF::URI('http://oregondigital.org/collections/cronk'),
      :'Oliver Matthews Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/mss_matthews'),
      :'Extension Bulletin Illustrations' => RDF::URI('http://data.library.oregonstate.edu/collection/p_020')
    }

    def collection(subject, data)
      collection = COLLECTION_URIS[data.to_sym] || data
      graph = RDF::Graph.new << RDF::Statement.new(subject, RDF::DC.isPartOf, collection)
      graph
    end
  end
end
