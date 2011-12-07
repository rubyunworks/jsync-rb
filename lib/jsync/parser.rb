require 'yaml'

module JSYNC

  #
  class Parser

    #
    def initialize
      @cache = {}
    end

    #
    def parse(jsync)
      data = YAML.load(jsync)
      evaluate(data)
    end

    #
    def evaluate(data)
      case data
      when Numeric, True, False, NilClass
        data
      when String
        if data.start_with?('*')
          @cache[data[1..-1]]
        elsif data.start_with?('!')
          i = data.index(' ')
          type = data[1..i]
          data = data[i+1..-1]
        elsif data.start_with?('.!')
          data = data[1..-1]
        else
          data
        end
      when Array
        data.map{ |e| evaluate(e) }
      else
        if data.key?('!')
          klass  = data['!']
          klass  = eval(klass, TOPLEVEL_BINDING)
          object = klass.allocate
          data.each do |k,v|
            next if k == '!'
            next if k == '&'
            object.instance_variable_set("@#{k}", v)
          end
          res = object
        else
          res = data.inject({}){ |h,(k,v)| h[k] = evaluate(v); h }
        end
        ## store in cache if anchored
        if data.key?('&')
          @cache[data['&']] = res
        end
        res
      end
    end

  end

  #
  def self.load(jsync)
    Parser.new.parse(jsync)
  end

end
