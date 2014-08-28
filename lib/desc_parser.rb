require 'ostruct'

class DescParser < OpenStruct
  def self.parse(file)
    hsh = {}
    all_desc = []
    get_tags(file).each do |tag, value|
      next if tag.nil? or tag == 'record' or tag == 'records'
      hsh[tag] = value
      if tag == "dmrecord"
        all_desc << new(hsh)
        hsh = {}
      end
    end
    return all_desc
  end

  def self.get_tags(file)
    File.read(file).scan(/<(.*)> *(.*) *<\/.*/)
  end
end
