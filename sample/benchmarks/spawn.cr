class MySpawn
  def task(channel : Channel(Int32))
    spawn do
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

      channel.send(r)
    end
  end

  def exec : Int32
    channel = Channel(Int32).new
    res = 0

    4.times do |_|
      task(channel)
    end

    4.times do |_|
      res += channel.receive
    end

    res
  end
end
