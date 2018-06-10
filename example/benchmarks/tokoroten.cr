require "../../src/tokoroten"

class MyWorker < Tokoroten::Worker
  def task(message : String)
    r = 0

    1000000000.times do |i|
      a = 0
      b = 1
      c = 2
      d = 3
      e = 4
      f = 5
      r = a + b - c + d - e + f
    end

    response(r.to_s)
  end
end

class MyTokoroten
  @workers : Array(Tokoroten::Worker)
  @result : Int32

  def initialize
    @workers = MyWorker.create(4)
    @result = 0
  end

  def exec : Int32
    @workers.each(&.exec)

    join

    @workers.each(&.kill)

    @result
  end

  def join
    @workers.each do |w|
      @result += w.receive.try &.to_i || 0
    end
  end
end
