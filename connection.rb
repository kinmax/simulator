class Connection
    attr_reader :src, :dst, :prob

    def initialize(src, dst, prob)
        @src = src
        @dst = dst
        @prob = prob
    end
end