library(httpuv)

port <- as.integer(Sys.getenv("PORT", "4029"))

app <- list(
  call = function(req) {
    list(
      status = 200L,
      headers = list("Content-Type" = "application/json"),
      body = '{"service":"r-app"}'
    )
  }
)

cat(sprintf("r-app listening on http://127.0.0.1:%d\n", port), file = stderr())
httpuv::runServer("127.0.0.1", port, app)
