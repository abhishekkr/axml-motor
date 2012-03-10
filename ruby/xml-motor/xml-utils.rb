module XMLUtils
  def self.dbqot_string(attrib_val)
    return nil if attrib_val.nil?
    matched_data = attrib_val.strip.match(/^'(.*)'$/)
    return attrib_val if matched_data.nil?
    matched_data = matched_data[0].gsub("\"","'")
    matched_data[0] = matched_data[-1] = "\""
    matched_data
  end
end
