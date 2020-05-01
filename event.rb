require "byebug"
class Event
    attr_accessor :treated
    attr_reader :id, :type, :time, :queue, :src, :dst, :connection

    VALID_TYPES = %w(entry exit transfer)

    def initialize(id, type, time, queue=nil, connection=nil, treated=false)
        if VALID_TYPES.include?(type)
            @id = id
            @type = type
            @time = time.round(4)
            @treated = false
            @queue = queue
            @connection = connection
            check_queue_params(type, queue, connection)
        else
            raise ArgumentError, "An invalid event type was passed for event id #{id}: #{type}. Valid event types: #{VALID_TYPES}"
        end
    end

    def deep_clone
        clone = Event.new(@id.clone, @type.clone, @time.clone, @queue.clone, @connection.clone, @treated.clone)
        return clone
    end

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