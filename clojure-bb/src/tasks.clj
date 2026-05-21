(ns tasks
  (:require [clojure.test :as t]))

(defn ^:export run-tests []
  (require 'core-test)
  (let [{:keys [fail error]} (t/run-tests 'core-test)]
    (System/exit (if (pos? (+ fail error)) 1 0))))
