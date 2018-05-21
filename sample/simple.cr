require "../src/tokoroten"

class MyWorker < Tokoroten::Worker
  def task(message : String)
    response("#{message}-ok")
  end
end

workers = MyWorker.create(4)
workers.each_with_index do |w, i|
  w.exec(i.to_s)
end

workers.each do |w|
  puts w.receive
end

workers.each do |w|
  w.kill
end
