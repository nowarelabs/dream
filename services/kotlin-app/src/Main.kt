import com.sun.net.httpserver.HttpServer
import java.net.InetSocketAddress
import java.nio.charset.StandardCharsets

fun main() {
    val port = System.getenv("PORT")?.toIntOrNull() ?: 4027
    val server = HttpServer.create(InetSocketAddress("0.0.0.0", port), 0)
    server.createContext("/") { exchange ->
        val body = "{\"service\":\"kotlin-app\"}".toByteArray(StandardCharsets.UTF_8)
        exchange.responseHeaders.set("content-type", "application/json")
        exchange.sendResponseHeaders(200, body.size.toLong())
        exchange.responseBody.use { it.write(body) }
    }
    server.start()
    println("kotlin-app listening on http://127.0.0.1:$port")
}