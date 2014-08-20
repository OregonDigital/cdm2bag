module MappingMethods
  module Collection

    COLLECTION_URIS = {
      :'John H. Gallagher Photography Collection' => RDF::URI('http://oregondigital.org/collections/gallagher'),
      :'Cronk Collection' => RDF::URI('http://oregondigital.org/collections/cronk'),
      :'Oliver Matthews Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/mss_matthews'),
      :'Extension Bulletin Illustrations' => RDF::URI('http://data.library.oregonstate.edu/collection/p_020'),
      :'Gifford Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_218'),
      :'Agricultural Experiment Station Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_019'),
      :'College of Forestry Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_061'),
      :'Extension Service Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_06'),
      :'Edwin Russell Jackman Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_089'),
      :'Agricultural Experiment Station Records' => RDF::URI('http://data.library.oregonstate.edu/collection/rg_02'),
      :'E. E. Wilson Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_101'),
      :'Extension and Experiment Station Communications' => RDF::URI('http://data.library.oregonstate.edu/collection/p_120'),
      :'Herbarium Department Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_093'),
      :'John Garman Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_095'),
      :'State of Oregon Board of Health' => RDF::URI('http://data.library.oregonstate.edu/collection/rg_231'),
      :"Harriet's Collection" => RDF::URI('http://data.library.oregonstate.edu/collection/p_hc'),
      :'Walter R. Baker Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_018'),
      :'News and Communication Services' => RDF::URI('http://data.library.oregonstate.edu/collection/rg_203'),
      :'Experiment Station Publications Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_132'),
      :'Fred P. Parcher Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_143'),
      :'Pernot Family Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_220'),
      :'Historical File, OSU' => RDF::URI('http://data.library.oregonstate.edu/collection/p_025'),
      :'Office of University Publications' => RDF::URI('http://data.library.oregonstate.edu/collection/p_094'),
      :'Woody Holderman Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_263'),
      :'Pass Creek Film Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/fv_p_273'),
      :'Harold Frodsham Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_271'),
      :'Robert W. Henderson Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_098'),
      :'Athletics -- Baseball' => RDF::URI('http://data.library.oregonstate.edu/collection/p_007'),
      :'Military Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_002'),
      :'Alumni Association Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/rg_035'),
      :'News and Communication Services' => RDF::URI('http://data.library.oregonstate.edu/collection/rg_203'),
      :'Beaver Yearbook Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_003'),
      :'Gwil Evans Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_082'),
      :'4-H Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_146'),
      :'Bill Reasons Photograph Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_151'),
      :'Robert \"Wally\" Reed Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_161'),
      :'Hawley Hall Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_167'),
      :'Harold Traxel Vedder Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_190'),
      :'James G. Arbuthnot Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_191'),
     # :'William Lester Powell and Lou Richards Photographic Collection' => RDF::URI(''),
      :'Intercollegiate Athletics' => RDF::URI('http://data.library.oregonstate.edu/collection/rg_007'),
      :'Richard W. Gilkey Photographic Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/p_252'),
      :'KBVR Photographs' => RDF::URI('http://data.library.oregonstate.edu/collection/p_170'),
      :'MSS - George Edmonston Collection' => RDF::URI('http://data.library.oregonstate.edu/collection/mss_edmonston'),
      :'Oregon Stater' => RDF::URI('http://data.library.oregonstate.edu/collection/p_195'),
     # :'Memorabilia Collection (MC-Baseball)' => RDF::URI(''),
      :'Sports Media Guides' => RDF::URI('http://data.library.oregonstate.edu/collection/pub_054'),
      :'Ava Helen and Linus Pauling Papers, Oregon State University Libraries Special Collections' => RDF::URI('http://data.library.oregonstate.edu/collection/mss_pauling'),
     # :'Memorabilia Collection (MC-Corvallis Indoor Baseball Club)' => RDF::URI(''),
     # :'Orange (Yearbook)' => RDF::URI(''),
     # :'' => RDF::URI(''),
      :'Fred Deininger Luse Photograph Album' => RDF::URI('http://data.library.oregonstate.edu/collection/p_228'),
      :'Paul Andresen Photographs' => RDF::URI('http://data.library.oregonstate.edu/collection/p_262'),
     # :'Orange and Black' => RDF::URI(''),
      :'Continuing Higher Education' => RDF::URI('http://data.library.oregonstate.edu/collection/p_048')
    }

    def collection(subject, data)
      collection = COLLECTION_URIS[data.to_sym] || data
      graph = RDF::Graph.new << RDF::Statement.new(subject, RDF::DC.isPartOf, collection)
      graph
    end
  end
end
