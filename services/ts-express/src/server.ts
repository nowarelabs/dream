import express from "express";

const port = Number(process.env.PORT ?? 3003);
const app = express();

app.get("/", (_req: express.Request, res: express.Response) => {
  res.json({ service: "ts-express", framework: "express" });
});

app.listen(port, () => {
  console.log(`ts-express listening on http://127.0.0.1:${port}`);
});