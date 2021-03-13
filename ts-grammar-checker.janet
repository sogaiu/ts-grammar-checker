(import ./support/path)
(import janet-tree-sitter/tree-sitter)

(defn has-ext?
  [file-path exts]
  (var matched false)
  (each ext exts
    (when (string/has-suffix? ext file-path)
      (set matched true)
      (break)))
  matched)

(comment

  (has-ext? "core.clj" [".clj" ".cljc" ".cljs"])
  # => true

  (has-ext? "boot.janet" [".janet"])
  # => true

  )

(defn check-dir
  [lang-name src-root exts]
  (def p (tree-sitter/init lang-name))
  (def subdirs @[])
  (defn helper
    [src-root subdirs]
    (each path (os/dir src-root)
      (def in-path (path/join src-root path))
      (case (os/stat in-path :mode)
        :directory
        (do
          (helper in-path (array/push subdirs path))
          (array/pop subdirs))
        #
        :file
        (when (has-ext? in-path exts)
          (when-let [t (try
                         (:parse-string p (string (slurp in-path)))
                         ([err]
                           (eprint err)
                           nil))]
            (when-let [r (:root-node t)]
              (when (:has-error r)
                (print in-path))))))))
  #
  (helper src-root subdirs))

(comment
  
  (check-dir
    "clojure" "/home/user/src/clojure" [".clj" ".cljc" ".cljs"])

  (check-dir
    "janet_simple" "/home/user/src/janet" [".janet"])

)

(defn main
  [& args]
  (unless (> (length args) 3)
    (eprint "Requires args for: lang-name, dir-path, extensions")
    (os/exit 1))
  (when-let [lang-name (get args 1)
             dir-path (get args 2)
             stat (os/stat dir-path)
             exts (slice args 3)]
    (unless (= :directory (stat :mode))
      (eprintf "dir-path was not a directory: %s" dir-path)
      (os/exit 1))
    (check-dir lang-name dir-path exts)))
