(ns clojure-compojure.core
  (:require [compojure.core :refer [defroutes GET]]
            [ring.adapter.jetty :refer [run-jetty]]))

(def ^:private body "{\"service\":\"clojure-compojure\",\"framework\":\"compojure\"}")

(defroutes app
  (GET "/" []
    {:status 200
     :headers {"content-type" "application/json"}
     :body body}))

(defn -main [& _]
  (let [port (Integer/parseInt (or (System/getenv "PORT") "3030"))]
    (println (str "clojure-compojure listening on http://127.0.0.1:" port))
    (run-jetty app {:port port :join? true})))
