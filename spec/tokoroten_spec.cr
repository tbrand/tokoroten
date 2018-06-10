require "./spec_helper"

include Tokoroten

class MyWorker < Worker
  def task(message : String)
    response(message + " -- response")
  end
end

class MyWorkerSleep < Worker
  def task(message : String)
    sleep 0.5
    response(message + " -- response")
  end
end

describe Worker do
  context "when call #create" do
    it "successfully create workers" do
      ws = MyWorker.create(2)
      ws.each do |w|
        w.exists?.should eq(true)
      end

      ws.each(&.kill)
      sleep 1

      ws.each do |w|
        w.exists?.should eq(false)
      end
    end
  end

  context "when execute tasks" do
    it "successfully completed a task with a worker" do
      ws = MyWorker.create(1)
      ws[0].exec("hoge")
      ws[0].receive.not_nil!.should eq("hoge -- response")
      ws[0].kill
    end

    it "successfully completed a task with a workers" do
      ws = MyWorker.create(4)

      4.times do |i|
        ws[i].exec("hoge")
        ws[i].receive.not_nil!.should eq("hoge -- response")
        ws[i].kill
      end
    end

    it "successfully completed tasks with a worker" do
      ws = MyWorker.create(1)
      ws[0].exec("hoge")
      ws[0].exec("hoge")
      ws[0].receive.not_nil!.should eq("hoge -- response")
      ws[0].receive.not_nil!.should eq("hoge -- response")
      ws[0].kill
    end

    it "successfully completed tasks with workers" do
      ws = MyWorker.create(4)

      4.times do |i|
        ws[i].exec("hoge")
        ws[i].exec("hoge")
        ws[i].receive.not_nil!.should eq("hoge -- response")
        ws[i].receive.not_nil!.should eq("hoge -- response")
        ws[i].kill
      end
    end
  end

  context "sequential writes" do
    it "successfully execute" do
      ws = MyWorker.create(1)
      ws[0].exec("hoge0")
      ws[0].exec("hoge1")
      ws[0].receive.not_nil!.should eq("hoge0 -- response")
      ws[0].receive.not_nil!.should eq("hoge1 -- response")
      ws[0].kill
    end

    it "successfully execute in multiple processes" do
      ws = MyWorker.create(2)
      ws[0].exec("hoge0")
      ws[0].exec("hoge1")
      ws[1].exec("hoge0")
      ws[1].exec("hoge1")

      ws[0].receive.not_nil!.should eq("hoge0 -- response")
      ws[0].receive.not_nil!.should eq("hoge1 -- response")
      ws[1].receive.not_nil!.should eq("hoge0 -- response")
      ws[1].receive.not_nil!.should eq("hoge1 -- response")
      ws[0].kill
      ws[1].kill
    end
  end

  context "text with new line" do
    it "successfully execute" do
      ws = MyWorker.create(1)
      ws[0].exec("ho\nge")
      ws[0].receive.not_nil!.should eq("ho\nge -- response")
      ws[0].kill
    end
  end

  context "big text" do
    it "successfully execute" do
      big_message = "abc\n\"\"}" * 10000

      ws = MyWorker.create(1)
      ws[0].exec(big_message)
      ws[0].receive.not_nil!.should eq(big_message + " -- response")
      ws[0].kill
    end

    it "successfully execute in multiple threads" do
      big_message = "abc\n\"\"}" * 10000

      nw = 5
      ws = MyWorker.create(nw)

      spawn do
        ws.each do |w|
          w.exec(big_message)
        end
      end

      ws.each do |w|
        w.receive.not_nil!.should eq(big_message + " -- response")
        w.kill
      end
    end

    it "successfully execute in multiple threads multiple times" do
      big_message = "abc\n\"\"}" * 10000

      nw = 5
      ne = 10
      ws = MyWorker.create(nw)

      spawn do
        ws.each do |w|
          ne.times do |_|
            w.exec(big_message)
          end
        end
      end

      ws.each do |w|
        ne.times do |_|
          w.receive.not_nil!.should eq(big_message + " -- response")
        end

        w.kill
      end
    end

    it "successfully execute in multiple threads and be executed in spawned thread multiple times" do
      big_message = "abc\n\"\"}" * 10000

      nw = 5
      ne = 10
      ws = MyWorker.create(nw)

      spawn do
        ws.each do |w|
          ne.times do |_|
            spawn do
              w.exec(big_message)
            end
          end
        end
      end

      ws.each do |w|
        ne.times do |_|
          w.receive.not_nil!.should eq(big_message + " -- response")
        end

        w.kill
      end
    end
  end
end
