#lang scribble/manual

@(require (for-label racket/base
                     sass))

@title{@exec{SASS}: Bindings to libsass}
@author[(author+email "Bogdan Popa" "bogdan@defn.io")]


@section[#:tag "intro"]{Introduction}

@(define libsass-uri "https://github.com/sass/libsass")

@exec{sass} exposes bindings to @link[libsass-uri]{libsass} via the FFI.


@section[#:tag "reference"]{Reference}
@defmodule[sass]

@deftogether[
  (@defproc[(compile/file [path path-string?]) string?]
   @defproc[(compile/bytes [data bytes?]) string?]
   @defproc[(compile/string [data string?]) string?])]{

  Compile a SCSS file, bytes or a string into a string of CSS.  Raises
  @racket[exn:fail:sass?] on error.
}

@deftogether[
  (@defproc[(exn:fail:sass? [v any/c]) boolean?]
   @defproc[(exn:fail:sass-code [e exn:fail:sass?]) exact-integer?])]{
}
