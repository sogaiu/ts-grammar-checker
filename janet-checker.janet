(import ./ts-grammar-checker)

(defn main
  [& args]
  (def n-args (length args))
  # XXX: not really appropriate for general use
  (var src-root   "/home/user/src/forcett/repos")
  (var lang-name "janet_simple")
  (var exts [".janet"])
  #
  (when (> n-args 1)
    (set src-root (get args 1)))
  (when (> n-args 2)
    (set lang-name (get args 2)))
  (when (> n-args 3)
    (set exts (slice args 3)))
  #
  (ts-grammar-checker/check-dir src-root lang-name exts))
