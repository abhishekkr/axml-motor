module XMLStdout

  def self._err(mesag)
    puts "ERROR:: #{mesag}" unless ENV['VERBOSE'].nil?
  end

  def self._nfo(mesag)
    puts "INFO:: #{mesag}" unless ENV['VERBOSE'].nil?
  end
end
