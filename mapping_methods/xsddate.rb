require 'rdf'

module MappingMethods
  module XSDDate
    def xsd_date(subject, predicate, data)
      if /^\d{4}(-\d{2})*$/.match(data)
        puts RDF::Statement.new(subject, predicate, RDF::Literal(data, :datatype => RDF::XSD.date))
        RDF::Statement.new(subject, predicate, RDF::Literal(data, :datatype => RDF::XSD.date))
      else
        string_date(subject, predicate, data)
      end
    end

    def xsd_datetime(subject, predicate, data)
      RDF::Statement.new(subject, predicate, RDF::Literal(data, :datatype => RDF::XSD.datetime))
    end

    def string_date(subject, predicate, data)
      RDF::Statement.new(subject, predicate, RDF::Literal(data))
    end

    def dc_date(subject, data)
      string_date(subject, RDF::DC.date, data)
    end

    def dc_created(subject, data)
      string_date(subject, RDF::DC.created, data)
    end

    def dc_modified(subject, data)
      string_date(subject, RDF::DC.modified, data)
    end

  end
end
