import { createServer } from "node:http";

const port = Number(process.env.PORT ?? 8000);

const server = createServer((req, res) => {
  res.setHeader("content-type", "application/json");

  if (req.url === "/health") {
    res.end(JSON.stringify({ status: "ok" }));
    return;
  }

  if (req.url === "/v1/systemone" && req.method === "POST") {
    req.on("data", () => {});
    req.on("end", () => {
      res.end(JSON.stringify({ model: "clef-flash-4bit", answers: {} }));
    });
    return;
  }

  res.statusCode = 404;
  res.end(JSON.stringify({ error: "not_found" }));
});

server.listen(port, () => {
  console.log(`dream listening on http://127.0.0.1:${port}`);
});
