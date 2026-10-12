(ns clojure-grpc.core
  (:import [io.grpc MethodDescriptor MethodDescriptor$MethodType Server ServerBuilder ServerServiceDefinition]
           [io.grpc.protobuf ProtoUtils]
           [io.grpc.stub ServerCalls ServerCalls$UnaryMethod StreamObserver]
           [echo EchoOuterClass$EchoRequest EchoOuterClass$EchoReply]))

(defn- say-method []
  (-> (MethodDescriptor/newBuilder)
      (.setType MethodDescriptor$MethodType/UNARY)
      (.setFullMethodName "echo.Echo/Say")
      (.setRequestMarshaller (ProtoUtils/marshaller (EchoOuterClass$EchoRequest/getDefaultInstance)))
      (.setResponseMarshaller (ProtoUtils/marshaller (EchoOuterClass$EchoReply/getDefaultInstance)))
      (.build)))

(defn- say-handler []
  (ServerCalls/asyncUnaryCall
   (reify ServerCalls$UnaryMethod
     (invoke [_ req observer]
       (.onNext ^StreamObserver observer
                (-> (EchoOuterClass$EchoReply/newBuilder)
                    (.setMessage (str "echo: " (.getMessage ^EchoOuterClass$EchoRequest req)))
                    (.build)))
       (.onCompleted ^StreamObserver observer)))))

(defn- service []
  (-> (ServerServiceDefinition/builder "echo.Echo")
      (.addMethod (say-method) (say-handler))
      (.build)))

(defn -main [& _]
  (let [port (Integer/parseInt (or (System/getenv "PORT") "50063"))
        server (-> (ServerBuilder/forPort port)
                   (.addService (service))
                   (.build)
                   (.start))]
    (println (str "clojure-grpc listening on 0.0.0.0:" port))
    (.awaitTermination ^io.grpc.Server server)))
