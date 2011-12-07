require 'set'

module JSYNC

  # JSYNC Emitter/Dumper.
  class Emitter

    #
    def initialize
      @cache = Set.new
    end

    #
    def emit(object)
      if @cache.include?(object)
        jout = "*" + @cache.index(object).to_s
      else
        jout = object.to_jsync_emit(self)
        case object
        when Numeric, True, False, NilClass
          # these are immutable, so are not cached
        else
          @cache << object
        end
      end
      jout
    end

  end

end


class Object

  # Serialize object in JSYNC format.
  def to_jsync
    JSYNC::Emitter.new.emit(self)
  end

  #
  def to_jsync_emit(emitter)
    data = {}
    instance_variables.each do |iv|
      key = iv.to_s[1..-1] 
      val = instance_variable_get(iv)
      data[key] = val
    end
    list = data.map do |k,v|
      r = emitter.emit(v)
      "#{k.inspect}: #{r}"
    end
    list.unshift %["!": "#{to_jsync_type}"]
    '{' + list.join(', ') + '}'
  end

  #
  def to_jsync_type
    self.class.name
  end
end

class Numeric
  # Serialize hash in JSYNC format.
  def to_jsync_emit(emitter)
    to_s
  end
  def to_jsync_type
    nil
  end
end

class String
  # Serialize hash in JSYNC format.
  def to_jsync_emit(emitter)
    if start_with?('!')
      ".#{self}".inspect
    else
      inspect
    end
  end
  def to_jsync_type
    nil
  end
end

class Hash
  def to_jsync_emit(emitter)
    list = map do |k,v|
      "#{k.inspect}: #{emitter.emit(v)}"
    end
    '{' + list.join(', ') + '}'
  end
  def to_jsync_type
    nil
  end
end

class Array
  def to_jsync_emit(emitter)
    list = data.map{ |e| emitter.emit(e) }.join(', ')
    '[' + list + ']'
  end
  def to_jsync_type
    nil
  end
end

class Time
  def to_jsync_emit(emitter)
    "!time #{utc}"
  end
  def to_jsync_type
    'time'
  end
end

class True
  def to_jsync_emit(emitter)
    'true'
  end
  def to_jsync_type
    nil
  end
end

class False
  def to_jsync_emit(emitter)
    'false'
  end
  def to_jsync_type
    nil
  end
end

class NilClass
  def to_jsync_emit(emitter)
    'null'
  end
  def to_jsync_type
    nil
  end
end

