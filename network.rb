class Network
    attr_reader :connections

    def initialize(connections)
        @connections = connections
    end

    def get_connections(queue)
        @connections.select { |con| con.src.label == queue.label }
    end
end