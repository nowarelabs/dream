library(plumber)

port <- as.integer(Sys.getenv("PORT", "3029"))

pr <- plumber::pr()
pr$handle("GET", "/", function() {
  list(service = "r-plumber", framework = "plumber")
}, serializer = plumber::serializer_unboxed_json())

pr$run(host = "127.0.0.1", port = port)
