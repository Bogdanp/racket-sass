#lang info

(define license 'BSD-3-Clause)
(define version "1.0")
(define collection "sass")
(define deps '("base"
               ("libsass-i386-win32" #:platform #rx"win32.i386")
               ("libsass-x86_64-linux" #:platform #rx"x86_64-linux")
               ("libsass-x86_64-macosx" #:platform #rx"x86_64-macosx")
               ("libsass-x86_64-win32" #:platform #rx"win32.x86_64")))
(define build-deps '("racket-doc"
                     "rackunit-lib"
                     "scribble-lib"
                     ("libsass-i386-win32" #:platform #rx"win32.i386")
                     ("libsass-x86_64-linux" #:platform #rx"x86_64-linux")
                     ("libsass-x86_64-macosx" #:platform #rx"x86_64-macosx")
                     ("libsass-x86_64-win32" #:platform #rx"win32.x86_64")))
(define scribblings '(("sass.scrbl")))
