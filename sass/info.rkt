#lang info

(define version "0.0.0")
(define collection "sass")
(define deps '("base" "libsass"))
(define build-deps '("racket-doc"
                     "rackunit-lib"
                     "scribble-lib"))
(define scribblings '(("sass.scrbl")))
