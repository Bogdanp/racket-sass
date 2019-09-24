#lang info

(define version "0.0.0")
(define collection "sass")
(define deps '("base"
               ("libsass-i386-win32" #:platform "win32\\i386")
               ("libsass-x86_64-linux" #:platform "x86_64-linux")
               ("libsass-x86_64-macosx" #:platform "x86_64-macosx")
               ("libsass-x86_64-win32" #:platform "win32\\x86_64")))
(define build-deps '("racket-doc"
                     "rackunit-lib"
                     "scribble-lib"))
(define scribblings '(("sass.scrbl")))
