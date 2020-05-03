# This class represents a network of connections between queues
class Network
    attr_reader :connections

    def initialize(connections)
        @connections = connections # an array of connections
    end

    # returns an array with all the connections that have the provided queue as source
    def get_connections(queue)
        @connections.select { |con| con.src.label == queue.label }
    end
end