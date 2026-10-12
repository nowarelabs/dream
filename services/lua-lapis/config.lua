local config = require("lapis.config")

config("development", {
  host = "127.0.0.1",
  port = tonumber(os.getenv("PORT")) or 3032
})
