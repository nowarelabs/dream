local lapis = require("lapis")

local app = lapis.Application()

app:get("/", function(self)
  return { json = { service = "lua-lapis", framework = "lapis" } }
end)

return app
