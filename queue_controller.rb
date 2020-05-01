class QueueController
    attr_reader :current_time, :states, :losses, :queues

    def initialize(first_entry, queue_for_first_entry, queues, network, random, scheduler)
        @queues = queues
        @network = network
        @first_entry = first_entry
        @scheduler = scheduler
        @random = random
        @current_time = 0.0
        @current_event = nil
        @randoms = []
        @scheduler.schedule("entry", @first_entry, queue_for_first_entry)
    end

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

    def entry(event)
        queues.each do |q|
            q.register_stat(q.state, event.time - @current_time)
        end
        q = queues.select { |q| event.queue.label == q.label }.first
        @current_time = event.time
        @current_event = event
        if q.state < q.capacity
            q.register_entry
            if q.state <= q.servers
                connection = @network.get_connections(q).first # temporary for tandem (without probabilities)
                event_type = connection.nil? ? "exit" : "transfer"
                @scheduler.schedule(event_type, (@current_time + @random.next_in_range(q.min_service, q.max_service)), q, connection)
                raise OutOfRandomsError if @random.see_next < 0
            end
        else
            q.register_loss
        end
        @scheduler.schedule("entry", (@current_time + @random.next_in_range(q.min_arrival, q.max_arrival)), q)
        raise OutOfRandomsError if @random.see_next < 0
    end

    def exit(event)
        queues.each do |q|
            q.register_stat(q.state, event.time - @current_time)
        end
        q = queues.select { |q| event.queue.label == q.label }.first
        @current_time = event.time
        @current_event = event
        q.register_exit
        if q.state >= q.servers
            @scheduler.schedule("exit", (@current_time + @random.next_in_range(q.min_service, q.max_service)), q)
        end
        raise OutOfRandomsError if @random.see_next < 0
    end
    
    def transfer(event)
        connection = event.connection
        src = queues.select { |q| connection.src.label == q.label }.first
        dst = queues.select { |q| connection.dst.label == q.label }.first
        dst = connection.dst
        queues.each do |q|
            q.register_stat(q.state, event.time - @current_time)
        end
        q = queues.select { |q| event.queue.label == q.label }.first
        @current_time = event.time
        @current_event = event
        src.register_exit
        if src.state >= src.servers
            @scheduler.schedule("transfer", (@current_time + @random.next_in_range(src.min_service, src.max_service)), src, connection)
            raise OutOfRandomsError if @random.see_next < 0
        end
        if dst.state < dst.capacity
            dst.register_entry
            if dst.state <= dst.servers
                @scheduler.schedule("exit", (@current_time + @random.next_in_range(dst.min_service, dst.max_service)), dst)
                raise OutOfRandomsError if @random.see_next < 0
            end
        else
            dst.register_loss
        end
    end
end