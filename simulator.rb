Dir["./*.rb"].each { |file| require file if file != "./simulator.rb" }
require "json"

start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

config_file_path = ARGV[0]
config_file = File.open(config_file_path)
raw_config = config_file.read
config = JSON.parse(raw_config)
avgs = []
avg_losses = []
qs = []

# set number of executions based on optional parameter
number_of_executions = config["executions"]
number_of_executions = 1 unless !number_of_executions.nil? && number_of_executions.is_a?(Integer)
number_of_executions = 1 if number_of_executions <= 0

# repeats according to number of executions
number_of_executions.times do  |index|
    random = PseudoRandomGenerator.new(config["randoms"]) # creates new pseudo-random generator (new seed)
    scheduler = Scheduler.new # creates new scheduler
    queues = []
    config["queues"].each do |item|
        queues << SimQueue.new(item["label"], 
                            item["capacity"],
                            item["servers"],
                            item["min_arrival"], 
                            item["max_arrival"], 
                            item["min_service"], 
                            item["max_service"]) # creates queues
    end
    qs = queues
    if index == 0
        queues.each do |q|
            avgs << []
            avg_losses << 0.to_f # initializes average losses for each queue
        end
    end
    net = []

    # create connections to be added to network
    config["network"].each do |item|
        source = queues.select { |q| q.label == item["source"] }.first
        destination = queues.select { |q| q.label == item["destination"] }.first
        net << Connection.new(source, destination, item["probability"])
    end

    network = Network.new(net) # create network with connections
    queue_controller = QueueController.new(config["first_entry"]["time"],
                                           queues.select { |q| q.label == config["first_entry"]["queue"] }.first,
                                           queues,
                                           network,
                                           random,
                                           scheduler) # create queue controller

    # keep treating events until no randoms are available
    ret = true
    while ret
        ret = queue_controller.treat_event(scheduler.next_event) 
    end
    
    # add stats and losses to average count
    queues.each_with_index do |q, i|
        avgs[i] << q.stats.map { |e| e.nil? ? 0.to_f : e }
        avg_losses[i] += q.losses
    end
end

# calculate average stats
final = []
avgs.each_with_index do |q, i|
    max = 0
    q.each do |x|
        max = x.length if x.length > max
    end
    q.each do |x|
        while x.length < max do
            x << 0.to_f
        end
    end
    final[i] = q.transpose.map {|x| x.reduce(:+)}
    final[i].each_with_index do |f, index|
        final[i][index] = (f.to_f/number_of_executions.to_f).round(4)
    end
end

# calculate average losses
final_losses = []
avg_losses.each do |q|
    final_losses << (q.to_f/number_of_executions.to_f).round(4)
end

# final output
puts "Results:\n\n"

qs.each_with_index do |q, i|
    puts "=======================================================\n\n"
    puts "Queue #{q.label} - G/G/#{q.servers}/#{q.capacity}\n\n"
    puts "State".ljust(20) + "Time".ljust(20) + "Probability".ljust(20)
    final[i].each_with_index do |stat, index|
        puts index.to_s.ljust(20) + stat.round(4).to_s.ljust(20) + ((stat/final[i].sum)*100.0).round(4).to_s + " %"
    end
    puts "\nTotal".ljust(21) + final[i].sum.round(4).to_s.ljust(20) + "100.0%"
    puts "\nAverage Losses: #{final_losses[i]}\n\n"
end

# Performance Indicators

puts "###########################################################"
puts "Performance Indicators"

qs.each_with_index do |q, i|
    mu = 1.to_f/((q.min_service + q.max_service)/2.to_f)
    puts "Queue #{q.label}"
    indicator_n = 0.to_f
    indicator_d = 0.to_f
    indicator_u = 0.to_f
    indicator_w = 0.to_f
    final[i].each_with_index do |stat, index|
        indicator_n += (stat/(final[i].sum)) * index
        indicator_d += (stat/(final[i].sum)) * mu*([q.servers, index].min)
        indicator_u += (stat/(final[i].sum)) * (([q.servers, index].min)/q.servers)
    end
    indicator_w = indicator_n/indicator_d
    puts "N = #{indicator_n}"
    puts "D = #{indicator_d}"
    puts "U = #{indicator_u}"
    puts "W = #{indicator_w}"
    puts "#########################################################"
end

end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = end_time - start_time # get real elapsed time
puts "\nSimulation Real Elapsed Time: #{elapsed.round(4)} seconds"