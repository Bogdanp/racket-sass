#lang info

(define version "0.0.0")
(define collection "sass")
(define deps '("base"
               ("libsass-x86_64-linux" #:platform "x86_64-linux")
               ("libsass-x86_64-macosx" #:platform "x86_64-macosx")))
(define build-deps '("racket-doc"
                     "rackunit-lib"
                     "scribble-lib"))
(define scribblings '(("sass.scrbl")))
