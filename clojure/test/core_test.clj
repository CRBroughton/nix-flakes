(ns core-test
  (:require [clojure.test :refer [deftest testing is]]
            [core :refer [greet]]))

(deftest greet-test
  (testing "returns hello string"
    (is (= "Hello, World!" (greet "World")))))
