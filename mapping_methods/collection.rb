module MappingMethods
  module Collection

    COLLECTION_URIS = {
      :'John H. Gallagher Photography Collection' => RDF::URI('http://oregondigital.org/collections/gallagher'),
      :'Cronk Collection' => RDF::URI('http://oregondigital.org/collections/cronk'),
      :'Oliver Matthews Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/mss_matthews'),
      :'Extension Bulletin Illustrations' => RFD::URI('http://data.library.oregonstate.edu/collection/p_020'),
      :'Gifford Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_218'),
      :'Agricultural Experiment Station Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_019'),
      :'College of Forestry Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_061'),
      :'Extension Service Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_06'),
      :'Edwin Russell Jackman Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_089'),
      :'Agricultural Experiment Station Records' => RFD::URI('http://data.library.oregonstate.edu/collection/rg_02'),
      :'E. E. Wilson Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_101'),
      :'Extension and Experiment Station Communications' => RFD::URI('http://data.library.oregonstate.edu/collection/p_120'),
      :'Herbarium Department Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_093'),
      :'John Garman Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_095'),
      :'State of Oregon Board of Health' => RFD::URI('http://data.library.oregonstate.edu/collection/rg_231'),
      :'Harriet\'s Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_hc'),
      :'Walter R. Baker Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_018'),
      :'News and Communication Services' => RFD::URI('http://data.library.oregonstate.edu/collection/rg_203'),
      :'Experiment Station Publications Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_132'),
      :'Fred P. Parcher Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_143'),
      :'Pernot Family Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_220'),
      :'Historical File, OSU' => RFD::URI('http://data.library.oregonstate.edu/collection/p_025'),
      :'Office of University Publications' => RFD::URI('http://data.library.oregonstate.edu/collection/p_094'),
      :'Woody Holderman Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_263'),
      :'Pass Creek Film Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/fv_p_273'),
      :'Harold Frodsham Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_271'),
      :'Robert W. Henderson Photographic Collection' => RFD::URI('http://data.library.oregonstate.edu/collection/p_098'),
    }

    def collection(subject, data)
      collection = COLLECTION_URIS[data.to_sym] || data
      graph = RDF::Graph.new << RDF::Statement.new(subject, RDF::DC.isPartOf, collection)
      graph
    end
  end
end
