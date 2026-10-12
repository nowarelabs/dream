import io.ktor.http.ContentType
import io.ktor.server.application.call
import io.ktor.server.engine.embeddedServer
import io.ktor.server.netty.Netty
import io.ktor.server.response.respondText
import io.ktor.server.routing.get
import io.ktor.server.routing.routing

fun main() {
    val port = System.getenv("PORT")?.toIntOrNull() ?: 3027
    println("kotlin-ktor listening on http://127.0.0.1:$port")
    val server = embeddedServer(Netty, port = port, host = "0.0.0.0") {
        routing {
            get("/") {
                call.respondText("""{"service":"kotlin-ktor","framework":"ktor"}""", ContentType.Application.Json)
            }
        }
    }
    server.start(wait = true)
}