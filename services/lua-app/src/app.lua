local socket = require("socket")

local port = tonumber(os.getenv("PORT") or "4032")
local server = assert(socket.bind("127.0.0.1", port))
server:settimeout(0)

io.stderr:write(string.format("lua-app listening on http://127.0.0.1:%d\n", port))

local body = '{"service":"lua-app"}'
local response = table.concat({
  "HTTP/1.1 200 OK",
  "content-type: application/json",
  "content-length: " .. #body,
  "connection: close",
  "",
  body,
}, "\r\n")

while true do
  local client = server:accept()
  if client then
    client:settimeout(2)
    client:receive("*l")
    while true do
      local line = client:receive("*l")
      if not line or line == "" then
        break
      end
    end
    client:send(response)
    client:close()
  else
    socket.sleep(0.01)
  end
end
