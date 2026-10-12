ThisBuild / scalaVersion := "2.13.15"

lazy val root = (project in file("."))
  .settings(
    name := "scala-http4s",
    version := "0.1.0",
    assembly / assemblyJarName := "scala-http4s.jar",
    assembly / mainClass := Some("Main"),
    libraryDependencies ++= Seq(
      "org.http4s" %% "http4s-ember-server" % "0.23.28",
      "org.http4s" %% "http4s-dsl" % "0.23.28"
    )
  )