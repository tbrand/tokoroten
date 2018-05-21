# tokoroten

tokoroten is one of the approach to use multiple processes in Crystal.

`spawn` is a good feature for executing light tasks concurrently.

For heavy tasks, tokoroten has an advantage compared to `spawn`.

See the below **Performance evaluation**.

## Performance evaluation

Compare the execution time of `spawn` and tokoroten By using `sample/benchmark.cr`.

In this example, tokoroten uses 4 processes.

```bash
Start benchmarking...

----- Tokoroten
=> 2.822[sec]

----- `spawn`
=> 10.704[sec]

tokoroten is about 4.0x faster than spawn
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  tokoroten:
    github: tbrand/tokoroten
```

## Usage

### Requirement
```crystal
require "tokoroten"
```

### Define woker
```crystal
class MyWorker < Tokoroten::Worker
  def task(message : String)
    #
    # Write your task using the `message`.
    # In this sample, just return a message with "-ok" prefix.
    # Use `response` when you create responses.
    #
    response("#{message}-ok")
  end
end
```

### Execute workers
```crystal
# Create 4 workers. (Using 4 processes)
workers = MyWorker.create(4)

# Execute each worker
workers.each_with_index do |w, i|
  w.exec(i.to_s)
end

# Join every workers (Syncronize point)
workers.each do |w|
  #
  # Receive result from a worker
  # The below `r` will be "0-ok", "1-ok"...
  #
  r = w.receive.try &.to_s || ""
end

# Clean up workers
workers.each do |w|
  w.kill
end
```

## Current restriction
Currently, communication between main process and worker processes are done by `String`.

So you can not pass arbitrary objects directly. (have to convert to string and re-convert from it.)

JSON serialization is one of the way to pass the objects.

```crystal
# main process => worker process
worker.exec(my_obj.to_json)
```

```crystal
# worker process => main process
MyObj.from_json(worker.receive.to_s)
```

## Contributing

1. Fork it ( https://github.com/tbrand/tokoroten/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [tbrand](https://github.com/tbrand) Taichiro Suzuki - creator, maintainer
