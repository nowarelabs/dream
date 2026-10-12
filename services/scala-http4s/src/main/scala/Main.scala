import cats.effect.IO
import cats.effect.IOApp
import com.comcast.ip4s._
import org.http4s.HttpRoutes
import org.http4s.MediaType
import org.http4s.Response
import org.http4s.Status
import org.http4s.dsl.io._
import org.http4s.ember.server.EmberServerBuilder
import org.http4s.headers.`Content-Type`

object Main extends IOApp.Simple {
  val routes = HttpRoutes.of[IO] {
    case GET -> Root =>
      IO.pure(
        Response[IO](status = Status.Ok)
          .withEntity("""{"service":"scala-http4s","framework":"http4s"}""")
          .putHeaders(`Content-Type`(MediaType.application.json))
      )
  }

  val run = {
    val port = sys.env.get("PORT").flatMap(_.toIntOption).getOrElse(3024)
    EmberServerBuilder
      .default[IO]
      .withHost(ipv4"0.0.0.0")
      .withPort(Port.fromInt(port).get)
      .withHttpApp(routes.orNotFound)
      .build
      .evalTap(_ => IO.println(s"scala-http4s listening on http://127.0.0.1:$port"))
      .useForever
  }
}