require "redis"
require "benchmark"
require "redis/connection/command_helper"

class Redis::Connection::Udp
  include Redis::Connection::CommandHelper

  def self.connect(config)
    socket = UDPSocket.new
    new(socket, config)
  end

  def connected?
    true
  end

  def write(command)
    command = build_command(command)
    @socket.send(command, 0, @host, @port)
  end

  def read
    "OK"
  end

  def initialize(socket, config)
    @socket = socket
    @host = config[:host]
    @port = config[:port]
  end

  def disconnect
  end
end

Redis::Connection.drivers << Redis::Connection::Udp

redis1 = Redis.new(driver: :ruby, lost: "127.0.0.1", port: 6379)
redis2 = Redis.new(lost: "127.0.0.1", port: 8789)

COUNT = 10000

puts "Ruby driver"
redis1.set "test1", 0
puts Benchmark.measure {
  COUNT.times { redis1.incr "test1" }
}
p redis1.get "test1"

puts "Udp driver"
redis1.set "test2", 0
puts Benchmark.measure {
  COUNT.times { redis2.incr "test2";  }
}
gets
val = redis1.get "test2"
p val
p val.to_f/COUNT

