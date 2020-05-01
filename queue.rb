class SimQueue
    attr_reader :capacity, :servers, :min_arrival, :max_arrival, :min_service, :max_service, :state, :label, :losses, :stats

    def initialize(label, capacity, servers, min_arrival=nil, max_arrival=nil, min_service, max_service)
        @label = label
        @capacity = capacity
        @servers = servers
        @min_arrival = min_arrival
        @max_arrival = max_arrival
        @min_service = min_service
        @max_service = max_service
        @state = 0
        @losses = 0
        @stats = []
        (@capacity+1).times do |i|
            @stats[i] = 0.to_f
        end
    end

    def register_entry
        if @state < capacity
            @state += 1
        else
            raise "Queue #{@label} is full. Cannot register entry."
        end
    end

    def register_exit
        if @state > 0
            @state -= 1
        else
            raise "Queue #{@label} is empty. Cannot register exit."
        end
    end
    
    def register_loss
        @losses += 1
    end

    def register_stat(state, time)
        @stats[state] += time
    end
end