require 'rdf'
module MappingMethods
  module Cleanup
    def baseball_cleanup(collection, graph, subject)
      # Clean up dates.
      dates = graph.query([nil, RDF::DC.date, nil]).group_by{|x| x.object.to_s}
      if dates.keys.length > 1
        remove_dates = dates.select{|key, value| !key.match(/[0-9]{4}-[0-9]{4}/).nil?}
        remove_dates.values.each do |remove_statement|
          remove_statement.each do |statement|
            graph.delete(statement)
          end
        end
      end
      graph
    end
  end
end
