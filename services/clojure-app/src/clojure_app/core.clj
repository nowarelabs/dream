(ns clojure-app.core
  (:import [java.net ServerSocket Socket]
           [java.io BufferedReader InputStreamReader]
           [java.nio.charset StandardCharsets]))

(def ^:private body "{\"service\":\"clojure-app\"}")

(defn- drain-request [^BufferedReader reader]
  (loop []
    (when-let [line (.readLine reader)]
      (when-not (empty? line)
        (recur)))))

(defn- handle [^Socket socket]
  (with-open [socket socket]
    (let [reader (BufferedReader. (InputStreamReader. (.getInputStream socket) StandardCharsets/UTF_8))
          out (.getOutputStream socket)]
      (drain-request reader)
      (.write out (.getBytes (str "HTTP/1.1 200 OK\r\n"
                                  "content-type: application/json\r\n"
                                  "content-length: " (count body) "\r\n"
                                  "connection: close\r\n\r\n"
                                  body)
                             StandardCharsets/UTF_8))
      (.flush out))))

(defn -main [& _]
  (let [port (Integer/parseInt (or (System/getenv "PORT") "4030"))]
    (println (str "clojure-app listening on http://127.0.0.1:" port))
    (with-open [server (ServerSocket. port)]
      (loop []
        (handle (.accept server))
        (recur)))))
