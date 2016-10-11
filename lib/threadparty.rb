require 'threadparty/threadpartyproxy'
require 'threadparty/partyproxies/processqueue'

##
#Handles the connection between PartyProxy classes,
#and how data is passed between them.
#
#Thanks to Gabe Berke-Williams and his article at
# https://robots.thoughtbot.com/writing-a-domain-specific-language-in-ruby
#for providing the examples and groundwork.
class ThreadParty

  ##
  #A list of PartyProxies that need to happen
  attr_accessor :to_process

  def initialize(&block)
    @to_process = Array.new
    add(&block) if block
    self
  end

  ##
  #Append a series PartyProxies to the to_process list.
  def add(&block)
    proxy = ThreadPartyProxy.new(self)
    proxy.instance_eval(&block)
  end

  ##
  #Perform XYZ one after another, returning nothing.
  def sequentially
    result = []
    @to_process.each do |party|
      result << party.execute
    end
    result.flatten
  end
  alias :conga :sequentially

  ##
  #Perform XYZ in different threads for maximum threadability.
  def pooled
    #WHY NOT USE OURSELF?
    #BWAHAHAHAHAHA
    ThreadParty.new do
      ProcessQueue do
        collection to_process
        threads to_process.length
        perform do |partyproxy|
          partyproxy.execute()
        end
      end
    end.sequentially
  end

  ##
  #Perform all XYZ using the products of X to call Y to call Z,
  #chaining and iterating on the resultes.
  #
  #Example:
  #  ThreadParty.new do
  #    ProcessQueue do
  #      queue s3_objects
  #      perform do |obj|
  #        download(obj)
  #      end
  #    end
  #
  #    ProcessQueue do
  #       perform fiddle_method
  #    end
  #
  #    ProcessQueue do
  #      #implicit "queue downloaded_and_fiddled_s3_objects"
  #      perform do |obj|
  #        upload_after_fiddle(obj)
  #      end
  #    end
  #  end
  def iteratively
    #lets get the party rolling
    result = @to_process.first.execute()
    #Now after the party is started,
    #do everything else.
    @to_process[1..-1].each do |party|
      #If a PartyProxy doesn't implement :queue,
      #it's not a party we want to give our innards to.
      if party.respond_to?(:queue)
        result = party.execute(result)
      else
        result = party.execute()
      end
    end
    result
  end
  alias :polka :iteratively

end
