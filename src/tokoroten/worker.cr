module Tokoroten
  abstract class Worker
    abstract def task(message : String)

    @process : Process?

    def self.create(num : Int32 = 1,
                    read_timeout : Int32? = nil) : Array(Worker)
      workers = [] of Worker

      num.times do |_|
        main_reader, main_writer = IO::Memory.pipe
        worker_reader, worker_writer = IO::Memory.pipe

        if read_timeout
          main_reader.read_timeout = read_timeout
          worker_reader.read_timeout = read_timeout
        end

        worker = new(main_reader, main_writer, worker_reader, worker_writer)
        worker.run
        workers << worker
      end
      workers
    end

    def initialize(@main_reader : IO::FileDescriptor, @main_writer : IO::FileDescriptor,
                   @worker_reader : IO::FileDescriptor, @worker_writer : IO::FileDescriptor)
    end

    def run
      @process = Process.fork do
        loop do
          next unless message = @worker_reader.gets(DELIMITER, true)

          spawn task(message)
        end
      end
    end

    def exec(message : String? = nil)
      spawn do
        @worker_writer.print "#{message}#{DELIMITER}"
      end
    end

    def response(message : String)
      @main_writer.print "#{message}#{DELIMITER}"
    end

    def receive : String?
      return nil unless message = @main_reader.gets(DELIMITER, true)

      message
    end

    def kill
      return unless process = @process
      process.kill
      @process = nil
    end

    def exists? : Bool
      return false unless process = @process
      return false unless process.exists?

      true
    end
  end
end
