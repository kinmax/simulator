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
number_of_executions = config["executions"]
number_of_executions = 1 unless !number_of_executions.nil? && number_of_executions.is_a?(Integer)
number_of_executions = 1 if number_of_executions <= 0
number_of_executions.times do  |index|
    random = PseudoRandomGenerator.new(config["randoms"])
    scheduler = Scheduler.new
    queues = []
    config["queues"].each do |item|
        queues << SimQueue.new(item["label"], 
                            item["capacity"],
                            item["servers"],
                            item["min_arrival"], 
                            item["max_arrival"], 
                            item["min_service"], 
                            item["max_service"])
    end
    qs = queues
    if index == 0
        queues.each do |q|
            avgs << []
            avg_losses << 0.to_f
        end
    end
    net = []
    config["network"].each do |item|
        source = queues.select { |q| q.label == item["source"] }.first
        destination = queues.select { |q| q.label == item["destination"] }.first
        net << Connection.new(source, destination, item["probability"])
    end
    network = Network.new(net)
    queue_controller = QueueController.new(config["first_entry"]["time"],
                                           queues.select { |q| q.label == config["first_entry"]["queue"] }.first,
                                           queues,
                                           network,
                                           random,
                                           scheduler)

    ret = true
    while ret
        ret = queue_controller.treat_event(scheduler.next_event) 
    end
    queues.each_with_index do |q, i|
        avgs[i] << q.stats.map { |e| e.nil? ? 0.to_f : e }
        avg_losses[i] += q.losses
    end
end

final = []
avgs.each_with_index do |q, i|
    final[i] = q.transpose.map {|x| x.reduce(:+)}
    final[i].each_with_index do |f, index|
        final[i][index] = (f.to_f/number_of_executions.to_f).round(4)
    end
end

final_losses = []
avg_losses.each do |q|
    final_losses << (q.to_f/number_of_executions.to_f).round(4)
end

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

end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = end_time - start_time
puts "\nSimulation Real Elapsed Time: #{elapsed.round(4)} seconds"