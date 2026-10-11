const { createServer } = require("node:http");

const port = Number(process.env.PORT ?? 4001);

createServer((req, res) => {
  res.setHeader("content-type", "application/json");
  res.end(JSON.stringify({ service: "node-app", path: req.url }));
}).listen(port, () => {
  console.log(`node-app listening on http://127.0.0.1:${port}`);
});
