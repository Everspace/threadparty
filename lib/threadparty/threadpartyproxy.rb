require 'objspace'
require 'threadparty/partyproxy'

##
#The DSL resolver for ThreadParty.
#
#It handles adding classes that inherited PartyProxy to the DSL,
#and executing them
class ThreadPartyProxy
  @thread_party
  @@proxables = {}

  def initialize(pool_party)
    @thread_party = pool_party
  end

  def self.add_proxy_reciever(klass)
    @@proxables[klass.name.to_sym] = klass
  end

  def method_missing(name, *args, &block)
    if @@proxables.has_key?(name) then
      perform_proxy(name, &block)
    else
      raise ArgumentError, "The bouncer says \"#{name}\" is not allowed at the thread party.\nIt is not inherited from PartyProxy"
    end
  end

  def perform_proxy(a_class, &block)
    party = @@proxables[a_class].new
    party.instance_eval(&block)
    @thread_party.to_process << party
  end
end