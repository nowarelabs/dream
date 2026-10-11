require "webrick"
require "json"

$stdout.sync = true

port = (ENV["PORT"] || 4002).to_i

server = WEBrick::HTTPServer.new(
  Port: port,
  Logger: WEBrick::Log.new($stdout, WEBrick::Log::INFO)
)

server.mount_proc "/" do |_req, res|
  res["Content-Type"] = "application/json"
  res.body = JSON.generate(service: "ruby-app")
end

trap("INT") { server.shutdown }

puts "ruby-app listening on http://127.0.0.1:#{port}"
server.start
