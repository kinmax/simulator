# This class controls the simulation
class QueueController
    attr_reader :current_time, :states, :losses, :queues

    # initializes the simulation and schedules first entry
    # receives the time for first entry, queue for first entry, queues involved in simulation, network of queues, pseudo-random generator and scheduler
    def initialize(first_entry, queue_for_first_entry, queues, network, random, scheduler)
        @queues = queues # queues involved
        @network = network # network of queues
        @first_entry = first_entry # time for first entry
        @scheduler = scheduler
        @random = random
        @current_time = 0.0
        @current_event = nil
        @randoms = []
        @scheduler.schedule("entry", @first_entry, queue_for_first_entry)
    end

    # receives an event an calls appropriate method based on event's type
    def treat_event(event)
        case event.type
            when "entry"
                entry(event)
            when "exit"
                exit(event)
            when "transfer"
                transfer(event)
        end
        return true
    rescue OutOfRandomsError => e
        return false
    end

    # handles an entry event
    def entry(event)
        queues.each do |q|
            q.register_stat(q.state, event.time - @current_time) # register stat for all queues (time count)
        end
        q = event.queue
        @current_time = event.time
        @current_event = event
        if q.state < q.capacity
            q.register_entry
            if q.state <= q.servers
                connections = @network.get_connections(q) # get all connections for queue
                connection = select_connection(connections) # handles probabilities
                event_type = connection.nil? ? "exit" : "transfer" # sets type for scheduling event
                @scheduler.schedule(event_type, (@current_time + @random.next_in_range(q.min_service, q.max_service)), q, connection) # schedules event
                raise OutOfRandomsError if @random.see_next < 0
            end
        else
            q.register_loss # if queue is full, register loss
        end
        @scheduler.schedule("entry", (@current_time + @random.next_in_range(q.min_arrival, q.max_arrival)), q) # schedule next entry
        raise OutOfRandomsError if @random.see_next < 0
    end

    # handles an exit event
    def exit(event)
        queues.each do |q|
            q.register_stat(q.state, event.time - @current_time) # register stat for all queues
        end
        q = event.queue
        @current_time = event.time
        @current_event = event
        q.register_exit # register exit
        if q.state >= q.servers
            connections = @network.get_connections(q) # get all connections for queue
            connection = select_connection(connections) # handles probabilities
            event_type = connection.nil? ? "exit" : "transfer" # sets type for scheduling event
            @scheduler.schedule(event_type, (@current_time + @random.next_in_range(q.min_service, q.max_service)), q, connection) # schedule event
        end
        raise OutOfRandomsError if @random.see_next < 0
    end
    
    # handles a transfer event
    def transfer(event)
        connection = event.connection
        src = connection.src
        dst = connection.dst
        queues.each do |q|
            q.register_stat(q.state, event.time - @current_time) # register stat for all queues
        end
        @current_time = event.time
        @current_event = event
        src.register_exit
        if src.state >= src.servers
            connections = @network.get_connections(src) # get all connections for queue
            connection = select_connection(connections) # handle probabilities
            event_type = connection.nil? ? "exit" : "transfer" # set type for scheduling event
            @scheduler.schedule(event_type, (@current_time + @random.next_in_range(src.min_service, src.max_service)), src, connection) # schedule event
            raise OutOfRandomsError if @random.see_next < 0
        end
        if dst.state < dst.capacity
            dst.register_entry
            if dst.state <= dst.servers
                connections = @network.get_connections(dst) # get all connections for queue
                connection = select_connection(connections) # handle probabilities
                event_type = connection.nil? ? "exit" : "transfer" # set type for scheduling event
                @scheduler.schedule(event_type, (@current_time + @random.next_in_range(dst.min_service, dst.max_service)), dst, connection) # schedule event
                raise OutOfRandomsError if @random.see_next < 0
            end
        else
            dst.register_loss
        end
    end

    private

    # method to select the connection based on the probability of it happening
    # receives an array of connections
    # returns a single connection if a connection between queues is selected
    # returns nil if the exit for the queue is selected
    def select_connection(cons)
        if cons.size == 1
            return cons.first if cons.first.prob == 1.0 # if only 1 connection an 100% prob to that, returns it
        end
        exit_probability = cons.size > 0 ? 1.to_f - cons.sum(&:prob) : 1.to_f
        exit_con = Connection.new(nil, nil, exit_probability) # a new connection representing exit is created
        return nil if exit_con.prob == 1.0 # if 100% prob to exit queue, return nil
        r = @random.next # uses a new random to see probability
        raise OutOfRandomsError if @random.see_next < 0
        connections = cons + [exit_con] # exit is added to connections list
        connections.sort_by!(&:prob) # sorts connections by probability
        connections.reverse! # reverses array to get connections by probability in descending order
        connections.each do |c|
            if r < c.prob
                return nil if c.src.nil? # if connection is exit, return nil
                return c # else return the connection
            end
        end
        return nil if connections.last.src.nil? # if connection is exit, return nil
        return connections.last # else return the connection
    end
end