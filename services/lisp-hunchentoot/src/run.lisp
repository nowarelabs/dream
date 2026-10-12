(require :asdf)

(defparameter *root* (merge-pathnames "../" *load-truename*))

(let ((setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file setup)
    (load setup)))

(unless (find-package :ql)
  (error "Quicklisp is not installed; install it or use the nix-built lisp-hunchentoot."))

(ql:quickload :hunchentoot :silent t)
(load (merge-pathnames "src/server.lisp" *root*))
(lisp-hunchentoot.core:main)
