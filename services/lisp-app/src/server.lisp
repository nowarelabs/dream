(require :sb-bsd-sockets)

(defparameter *body* "{\"service\":\"lisp-app\"}")

(defun read-request-headers (stream)
  (loop for line = (read-line stream nil nil)
        while (and line (plusp (length (string-right-trim '(#\Return #\Newline) line))))))

(defun write-response (stream)
  (write-string
   (concatenate 'string
                "HTTP/1.1 200 OK" (string #\Return) (string #\Linefeed)
                "content-type: application/json" (string #\Return) (string #\Linefeed)
                "content-length: " (princ-to-string (length *body*)) (string #\Return) (string #\Linefeed)
                "connection: close" (string #\Return) (string #\Linefeed)
                (string #\Return) (string #\Linefeed)
                *body*)
   stream)
  (force-output stream))

(defun handle-client (socket)
  (let ((stream (sb-bsd-sockets:socket-make-stream socket :input t :output t :element-type 'character)))
    (unwind-protect
         (progn
           (read-request-headers stream)
           (write-response stream))
      (close stream))))

(defun main ()
  (let* ((port (parse-integer (or (sb-ext:posix-getenv "PORT") "4031")))
         (server (make-instance 'sb-bsd-sockets:inet-socket :type :stream :protocol :tcp)))
    (setf (sb-bsd-sockets:sockopt-reuse-address server) t)
    (sb-bsd-sockets:socket-bind server #(0 0 0 0) port)
    (sb-bsd-sockets:socket-listen server 10)
    (format t "lisp-app listening on http://127.0.0.1:~D~%" port)
    (force-output)
    (loop for client = (sb-bsd-sockets:socket-accept server)
          do (handler-case (handle-client client)
               (error (e)
                 (format *error-output* "lisp-app: ~A~%" e)
                 (ignore-errors (sb-bsd-sockets:socket-close client)))))))

(main)
