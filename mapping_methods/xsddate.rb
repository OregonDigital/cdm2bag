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

    def dc_date_collected(subject, date)

      # Make sure that the date has two digits for month and day, padding if necessary.
      parts = date.split('-')
      case parts.count
        when 3
          date = sprintf("%s-%02d-%02d",parts[0], parts[1], parts[2])
        when 2
          date = sprintf("%s-%02d",parts[0], parts[1])
        else
          # Just use the date as is.
      end
      string_date(subject, RDF::URI.new(@namespaces['oregon']['collectedDate']), date)
    end

  end
end
