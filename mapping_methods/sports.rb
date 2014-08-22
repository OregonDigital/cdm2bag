module MappingMethods
  module Sports
    def sports_team(subject, data)
      g = RDF::Graph.new
      data.split(";").each do |team|
        team.strip!
        g << RDF::Statement.new(subject, RDF::URI("http://opaquenamespace.org/ns/sportsTeam"), team)
      end
      g
    end
  end
end
