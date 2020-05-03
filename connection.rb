# This class describes a connection between 2 queues
class Connection
    attr_reader :src, :dst, :prob

    def initialize(src, dst, prob)
        @src = src # source queue
        @dst = dst # destination queue
        @prob = prob # routing probability
    end
end