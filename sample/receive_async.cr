require "../src/tokoroten"

class MyWorker < Tokoroten::Worker
  def task(message : String)
    sleep 0.5
    response("#{message}-ok")
  end
end

class MyMaster
  @workers : Array(Tokoroten::Worker)
  @results : Array(String) = [] of String

  def initialize
    @workers = MyWorker.create(4)
  end

  def run
    @workers.each_with_index do |w, i|
      w.exec(i.to_s)
    end

    @workers.each do |w|
      spawn do
        @results << w.receive.to_s
      end
    end
  end

  def wait
    sleep 5

    p @results

    @workers.each do |w|
      w.kill
    end
  end
end

my_master = MyMaster.new
my_master.run
my_master.wait
