require 'ostruct'

class DescParser < OpenStruct
  def self.parse(file)
    hsh = {}
    all_desc = []
    File.readlines(file).each do |line|
      tag, value = parse_tag(line)
      next if tag.nil? or tag == 'record' or tag == 'records'
      hsh[tag] = value
      if tag == "dmrecord"
        all_desc << new(hsh)
        hsh = {}
      end
    end
    return all_desc
  end

  def self.parse_tag(tag)
    tag.match(/<(.*)> *(.*) *<.*/).to_a.slice(1,2)
  end
end
