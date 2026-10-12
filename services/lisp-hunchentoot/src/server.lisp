(defpackage #:lisp-hunchentoot.core
  (:use #:cl)
  (:export #:main))

(in-package #:lisp-hunchentoot.core)

(hunchentoot:define-easy-handler (home :uri "/") ()
  (setf (hunchentoot:content-type*) "application/json")
  "{\"service\":\"lisp-hunchentoot\",\"framework\":\"hunchentoot\"}")

(defun main ()
  (let ((port (parse-integer (or (sb-ext:posix-getenv "PORT") "3031"))))
    (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port port :address "0.0.0.0"))
    (format t "lisp-hunchentoot listening on http://127.0.0.1:~D~%" port)
    (force-output)
    (loop (sleep 3600))))
