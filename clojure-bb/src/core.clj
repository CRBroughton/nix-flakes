(ns core)

(defn greet
  "Returns a greeting string for the given name."
  [name]
  (str "Hello, " name "!"))

(defn -main
  "Entry point. Greets the first CLI arg, or 'World' if none provided."
  [& args]
  (-> args
      first
      (or "World")
      greet
      println))

(-main)
