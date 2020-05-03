# This class describes an event
class Event
    attr_accessor :treated
    attr_reader :id, :type, :time, :queue, :src, :dst, :connection

    VALID_TYPES = %w(entry exit transfer)

    def initialize(id, type, time, queue=nil, connection=nil, treated=false)
        if VALID_TYPES.include?(type)
            @id = id # unique id for event
            @type = type # type of event (entry, transfer or exit)
            @time = time.round(4) # time of event
            @treated = false # flag that says if event was treated or not
            @queue = queue # queue that called the event
            @connection = connection # connection that called the event
            check_queue_params(type, queue, connection)
        else
            raise ArgumentError, "An invalid event type was passed for event id #{id}: #{type}. Valid event types: #{VALID_TYPES}"
        end
    end

    # method that checks validity of queu params
    # an entry or exit cannot have queue parameter as nil
    # a transfer cannot have connection as nil
    # receives type of event, the queue parameter and the connection parameter
    # raises exception in case of wrong params
    def check_queue_params(type, queue, connection)
        if type == "entry" || type == "exit"
            if queue.nil? || !connection.nil?
                raise ArgumentError, "Event type is #{type} but queue is nil or connection isn't"
            end
        else
            if queue.nil? || connection.nil?
                raise ArgumentError, "Event type is #{type} but connection is nil or queue is nil"
            end
        end
    end
end