# This class describes a connection between 2 queues
class Connection
    attr_reader :src, :dst, :prob

    def initialize(src, dst, prob)
        @src = src # source queue
        @dst = dst # destination queue
        @prob = prob # routing probability
    end

    def to_s
        "Source: #{@src&.label}\nDestination: #{@dst&.label}\nProbability: #{@prob}\n"
    end
end