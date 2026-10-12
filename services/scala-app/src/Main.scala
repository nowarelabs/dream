import com.sun.net.httpserver.HttpServer
import java.net.InetSocketAddress
import java.nio.charset.StandardCharsets

object Main {
  def main(args: Array[String]): Unit = {
    val port = sys.env.getOrElse("PORT", "4024").toInt
    val server = HttpServer.create(new InetSocketAddress("0.0.0.0", port), 0)
    server.createContext("/", (exchange: com.sun.net.httpserver.HttpExchange) => {
      val body = "{\"service\":\"scala-app\"}".getBytes(StandardCharsets.UTF_8)
      exchange.getResponseHeaders.set("content-type", "application/json")
      exchange.sendResponseHeaders(200, body.length.toLong)
      val out = exchange.getResponseBody
      try out.write(body)
      finally out.close()
    })
    server.start()
    println("scala-app listening on http://127.0.0.1:" + port)
  }
}