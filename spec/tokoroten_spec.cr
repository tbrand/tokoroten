require "./spec_helper"

include Tokoroten

class MyWorker < Worker
  def task(message : String)
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
end
