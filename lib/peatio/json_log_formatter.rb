class JSONLogFormatter < ::Logger::Formatter
  def call(severity, time, _progname, msg)
      begin
        obj = JSON.parse msg
      rescue StandardError
        obj = msg
      end
      if obj.is_a? Hash
        # String keys: merging symbol keys into a parsed (string-keyed) hash produced
        # duplicate "level"/"time" keys (json 3 raises on that).
        JSON.dump(obj.transform_keys(&:to_s).merge('level' => severity, 'time' => time)) + "\n"
      else
        JSON.dump(level: severity, time: time, message: msg) + "\n"
      end
  end
end
