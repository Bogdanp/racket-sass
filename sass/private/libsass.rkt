#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define)

(provide
 bytes->unmanaged-cstring

 libsass_version
 libsass_language_version

 sass_context_get_options
 sass_context_get_output_string
 sass_context_get_error_message

 sass_make_data_context
 sass_delete_data_context
 sass_data_context_get_context
 sass_compile_data_context

 sass_make_file_context
 sass_delete_file_context
 sass_file_context_get_context
 sass_compile_file_context)

(define (bytes->unmanaged-cstring bs)
  (define sz (bytes-length bs))
  (define p (malloc 'raw (add1 sz)))
  (begin0 p
    (memcpy p bs sz)
    (memset p sz 0 1)))

;; Basics ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-ffi-definer define-sass (ffi-lib "libsass"))

(define-sass libsass_version (_fun -> _string))
(define-sass libsass_language_version (_fun -> _string))


;; Sass_Options ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define _Sass_Options-pointer (_cpointer 'Sass_Options))


;; Sass_Context ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define _Sass_Context-pointer (_cpointer 'Sass_Context))
(define-sass sass_context_get_options (_fun _Sass_Context-pointer -> _Sass_Options-pointer))
(define-sass sass_context_get_output_string (_fun _Sass_Context-pointer -> _string))
(define-sass sass_context_get_error_message (_fun _Sass_Context-pointer -> _string))


;; Sass_Data_Context ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define _Sass_Data_Context-pointer (_cpointer 'Sass_Data_Context))

(define-sass sass_make_data_context (_fun _pointer -> _Sass_Data_Context-pointer))
(define-sass sass_delete_data_context (_fun _Sass_Data_Context-pointer -> _void))
(define-sass sass_data_context_get_context (_fun _Sass_Data_Context-pointer -> _Sass_Context-pointer))
(define-sass sass_compile_data_context (_fun _Sass_Data_Context-pointer -> _int))


;; Sass_File_Context ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define _Sass_File_Context-pointer (_cpointer 'Sass_File_Context))

(define-sass sass_make_file_context (_fun _path -> _Sass_File_Context-pointer))
(define-sass sass_delete_file_context (_fun _Sass_File_Context-pointer -> _void))
(define-sass sass_file_context_get_context (_fun _Sass_File_Context-pointer -> _Sass_Context-pointer))
(define-sass sass_compile_file_context (_fun _Sass_File_Context-pointer -> _int))
