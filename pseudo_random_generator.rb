class PseudoRandomGenerator
    def initialize(numbers=100000)
        m = 2**32
        a = 1664525
        c = 1013904223
        x0 = Time.now.to_i
        n = numbers
    
        numbers = Array.new(n+1)
        @normalized_numbers = Array.new(n)
    
        numbers.each_with_index do |num, index|
            if index == 0
                numbers[index] = x0
            else
                numbers[index] = (a * numbers[index-1] + c)%m
                @normalized_numbers[index-1] = numbers[index].to_f/m.to_f
            end
        end
        @index = 0
    end

    def next        
        if @index == @normalized_numbers.length
            raise OutOfRandomsError
        else
            norm = @normalized_numbers[@index].round(4)
            @index += 1
            return norm
        end
    end

    def next_in_range(a, b)
        ((b - a).to_f.round(4) * self.next + a.to_f.round(4)).round(4)
    end

    def see_next
        if @index == @normalized_numbers.length
            return -1
        else
            return @normalized_numbers[@index].round(4)
        end
    end
end
