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
  [src-root lang-name exts &opt so-path]
  (def p
    (if so-path
      (tree-sitter/init lang-name so-path)
      (tree-sitter/init lang-name)))
  (unless p
    (eprintf "") # aesthetics
    (errorf "Parser init failed"))
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
    "/home/user/src/clojure" "clojure" [".clj" ".cljc" ".cljs"])

  (check-dir
    "/home/user/src/janet" "janet_simple" [".janet"])

  )

(defn main
  [& args]
  (unless (> (length args) 3)
    (eprint "Requires at least: dir-path, lang-name, extensions")
    (os/exit 1))
  (when-let [dir-path (get args 1)
             stat (os/stat dir-path)
             lang-name (get args 2)
             rest (array ;(slice args 3))
             last-item (last rest)]
    (unless (= :directory (stat :mode))
      (eprintf "dir-path was not a directory: %s" dir-path)
      (os/exit 1))
    # if last-item has a "." in it, assume it's a path -- hacky?
    (if (string/find "." last-item)
      # found a path
      (check-dir dir-path lang-name (array/remove rest -2) last-item)
      # no path, so rest only has extensions
      (check-dir dir-path lang-name rest))))
