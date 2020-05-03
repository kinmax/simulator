# This class represents the events scheduler
class Scheduler
    # initializes an empty array of events
    def initialize
        @events = []
    end

    # schedules a new event
    # receives the event type, event time, queue related and connection related (if any)
    # returns new event
    def schedule(event_type, time, queue, connection=nil)
        new_event = Event.new(@events.length+1, event_type, time, queue, connection) # adds id to event as well
        @events << new_event
        @events.sort_by!{ |event| event.time } # sorts events by time, to always get the next event
        return new_event
    end

    # returns the next event on the list
    def next_event
        event = @events.shift # shifts the array, returning next event and removing it from the array
        event.treated = true # sets event's treated flag to true
        return event
    end
end