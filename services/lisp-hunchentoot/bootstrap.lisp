(require :asdf)

(defparameter *root* (merge-pathnames "" *load-truename*))

(load (merge-pathnames "quicklisp.lisp" (user-homedir-pathname)))
(quicklisp-quickstart:install)
(load (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname)))
(ql:quickload :hunchentoot)
(load (merge-pathnames "src/server.lisp" *root*))

(sb-ext:save-lisp-and-die (make-pathname :name "lisp-hunchentoot" :type "core" :defaults *root*)
                          :toplevel 'lisp-hunchentoot.core:main)
