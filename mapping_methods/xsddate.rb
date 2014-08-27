require 'rdf'

module MappingMethods
  module XSDDate
    def xsd_date(subject, data)
      predicate = RDF::DC.date
      if /^\d{4}(-[0-9]{2}){2}$/.match(data) && !data.include?("-00")
        RDF::Statement.new(subject, predicate, RDF::Literal(data, :datatype => RDF::XSD.date))
      else
        string_date(subject, predicate, data)
      end
    end

    def baseball_date(subject, date)
      date = date.gsub(",",";") || date
      date = date.split(";").map{|x| x.to_i}
      date = "#{date.min}-#{date.max}"
      xsd_date(subject, date)
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
