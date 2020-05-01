class Scheduler
    def initialize
        @events = []
    end

    def schedule(event_type, time, queue, connection=nil)
        new_event = Event.new(@events.length+1, event_type, time, queue, connection)
        @events << new_event
        @events.sort_by!{ |event| event.time }
        return new_event.deep_clone
    end

    def next_event
        event = @events.shift
        event.treated = true
        return event.deep_clone
    end
end