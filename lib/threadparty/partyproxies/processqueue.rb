require 'threadparty/partyproxy'
require 'threadparty/queue'

class ProcessQueue < PartyProxy
  is_proxy
  dsl_method :perform, :ensure
  dsl_accessor :queue, :modify_queue

  def initialize
    super
    @modify_queue = false
  end

  def execute(queue_override = nil)
    raise ArgumentError, 'I don\'t have a perform' unless @perform

    process_queue = Queue.new()
    result_queue = Queue.new()

    #Oldstuff gets pushed in first
    [queue_override, @queue].each do |possible_things|
      case possible_things
      when Queue
        possible_things.to_a!
      else
        possible_things.to_a
      end.each do |thing|
        process_queue.push(thing)
      end
    end

    threaded do |number|
      while item = process_queue.pop(true)
        case @perform.arity
        when 0
          result_queue << @perform.call()
        when 1
          result_queue << @perform.call(
              @modify_queue ? process_queue : item
            )
        else
          result_queue << @perform.call(
              @modify_queue ? process_queue : item,
              *item
            )
        end
      end
    end
    result_queue.to_a!
  end
end