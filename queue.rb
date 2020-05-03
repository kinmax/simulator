# This  class represents a queue
class SimQueue
    attr_reader :capacity, :servers, :min_arrival, :max_arrival, :min_service, :max_service, :state, :label, :losses, :stats

    def initialize(label, capacity, servers, min_arrival=nil, max_arrival=nil, min_service, max_service)
        @label = label # unique label for queue
        @capacity = capacity || Float::INFINITY # capacity of queue. If nil, infinity
        @servers = servers # number of servers
        @min_arrival = min_arrival # minimum arrival time
        @max_arrival = max_arrival # maximum arrival time
        @min_service = min_service # minimum service time
        @max_service = max_service # maximum service time
        @state = 0 # number of users in queue
        @losses = 0 # total number os losses
        @stats = [] # total time for each state
    end

    # registers an entry
    # increases state if queue is not full or else raises an exception
    def register_entry
        if @state < capacity
            @state += 1
        else
            raise "Queue #{@label} is full. Cannot register entry."
        end
    end

    # registers an exit
    # decreases state if queue is not empty or else raises an exception
    def register_exit
        if @state > 0
            @state -= 1
        else
            raise "Queue #{@label} is empty. Cannot register exit."
        end
    end
    
    # registers a loss
    def register_loss
        @losses += 1
    end

    # register more time for a given state
    def register_stat(state, time)
        @stats[state] = 0.to_f if @stats[state].nil?
        @stats[state] += time
    end
end