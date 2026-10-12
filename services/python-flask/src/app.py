import json
import os
from flask import Flask, Response

app = Flask(__name__)
PORT = int(os.environ.get("PORT", "3028"))


@app.get("/")
def home():
    return Response(
        json.dumps({"service": "python-flask", "framework": "flask"}),
        content_type="application/json",
    )


if __name__ == "__main__":
    print(f"python-flask listening on http://127.0.0.1:{PORT}", flush=True)
    app.run(host="127.0.0.1", port=PORT)
