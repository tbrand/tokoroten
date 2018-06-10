require "./benchmarks/*"
require "big"
require "colorize"

def benchmark(target)
  s = Time.now
  r = target.new.exec

  raise "invalid result for #{target}" unless r == 12

  e = Time.now

  min = (e - s).minutes * 60
  sec = (e - s).seconds
  mec = (e - s).milliseconds * 0.001

  t = min + sec + mec

  puts "=> #{t}[sec]"

  t
end

puts "Start benchmarking..."
puts ""
puts "----- Tokoroten"
tokoroten_time = benchmark(MyTokoroten)
puts ""
puts "----- `spawn`"
spawn_time = benchmark(MySpawn)
puts ""
puts ""
puts "Tokoroten is about #{(spawn_time.to_f/tokoroten_time.to_f).round.to_s.colorize.mode(:bold).fore(:light_green)}x faster than spawn"
