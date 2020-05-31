# This class is a pseudo-random numbers generator
class PseudoRandomGenerator

    # generates the list of pseudo-random numbers
    def initialize(numbers=100000)
        if numbers.is_a?(Integer) # if user provided the number of randoms, generate them using linear congruent method
            m = 2**32
            a = 1664525
            c = 1013904223
            x0 = Time.now.to_i # uses current timestamp as seed
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
        else # if user provided a list of numbers, use it
            @normalized_numbers = numbers
            @index = 0
        end       
    end

    # returns next number on the list and increases index to prepare for next
    def next        
        if @index == @normalized_numbers.length
            raise OutOfRandomsError
        else
            norm = @normalized_numbers[@index].round(4)
            @index += 1
            return norm
        end
    end

    # gets next number in a given range (a..b)
    def next_in_range(a, b)
        ((b - a).to_f * self.next + a.to_f)
    end

    # returns the next number without altering index
    def see_next
        if @index >= @normalized_numbers.length
            return -1
        else
            return @normalized_numbers[@index]
        end
    end
end
