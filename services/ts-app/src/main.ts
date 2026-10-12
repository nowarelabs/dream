import { createServer } from "node:http";

const port = Number(process.env.PORT ?? 4003);

createServer((_req, res) => {
  res.setHeader("content-type", "application/json");
  res.end(JSON.stringify({ service: "ts-app", runtime: "typescript" }));
}).listen(port, () => {
  console.log(`ts-app listening on http://127.0.0.1:${port}`);
});