require 'thread'
require 'threadparty/threadpartyproxy'

class PartyProxy

  # Allow for for an easy way to add dsl words that are simply
  # setters.
  #
  # class PartyProxyChild < PartyProxy
  #    dsl_accessor :set_this
  # end
  #
  # PartyProxyChild do
  #  set_this value
  # end
  #
  # This also defines get_#{symbol} to allow for
  # "normal" access to the variable outside of dsl context.
  def self.dsl_accessor(*symbols)
    symbols.each do |symbol|
      instance_symbol = "@#{symbol}".to_sym
      define_method(symbol) do |value|
        instance_variable_set(instance_symbol, value)
      end
    end
  end

  ##
  # Method that is a nice way to say that I'm going to be
  # a proxy.
  def self.is_proxy
    ThreadPartyProxy.add_proxy_reciever self
  end

  # Allow for for an easy way to add dsl methods that are blocks.
  #
  # class PartyProxyChild < PartyProxy
  #    dsl_method :do_this
  # end
  #
  # PartyProxyChild do
  #  collection ["left", "right"]
  #  do_this {|hand| puts "your #{hand} in!"}
  # end
  #
  def self.dsl_method(*symbols)
    symbols.each do |symbol|
      instance_symbol = "@#{symbol}".to_sym
      define_method symbol do |&block|
        instance_variable_set instance_symbol, block
      end
    end
  end

  dsl_accessor :abort_on_exception, :threads, :join

  def initialize
    @abort_on_exception = false
    @join = true
    @threads = 8
  end


  def threaded
    threads = (0...@threads).collect do |number|
      Thread.new do
        Thread.current.abort_on_exception = @abort_on_exception
        begin
          yield number
        rescue ThreadError
        end
      end
    end
    threads.each(&:join) if @join
  end

  #Execute should return the results of each thread's to-do.
  def execute
  end

end