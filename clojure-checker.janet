(import ./ts-grammar-checker)

(ts-grammar-checker/check-dir
  "clojure"
  "/home/user/src/clojars-cljish"
  [".clj" ".cljc" ".cljs"])
