#lang racket/base

(require racket/contract
         racket/string
         "private/libsass.rkt")

(provide
 (struct-out exn:fail:sass)

 (rename-out [libsass_version sass-version]
             [libsass_language_version sass-language-version])

 compile/file
 compile/bytes
 compile/string)

(struct exn:fail:sass exn:fail (code))

(define (raise-context-error context code)
  (define message (sass_context_get_error_message context))
  (raise (exn:fail:sass message (current-continuation-marks) code)))

(define/contract (compile/file path)
  (-> path-string? string?)
  (define context #f)

  (dynamic-wind
    (lambda _
      (set! context (sass_make_file_context (path->complete-path path))))
    (lambda _
      (define code (sass_compile_file_context context))
      (case code
        [(0) (sass_context_get_output_string (sass_file_context_get_context context))]
        [else (raise-context-error (sass_file_context_get_context context) code)]))
    (lambda _
      (sass_delete_file_context context))))

(define/contract (compile/bytes data)
  (-> bytes? string?)
  (define context #f)

  (dynamic-wind
    (lambda _
      ;; Sass_Data_Context frees the string that gets passed into it after
      ;; compilation so we have to copy the input string and ensure that the
      ;; resulting copy isn't managed by the GC.
      (set! context (sass_make_data_context (bytes->unmanaged-cstring data))))
    (lambda ()
      (define code (sass_compile_data_context context))
      (case code
        [(0) (sass_context_get_output_string (sass_data_context_get_context context))]
        [else (raise-context-error (sass_data_context_get_context context) code)]))
    (lambda ()
      (sass_delete_data_context context))))

(define/contract (compile/string data)
  (-> non-empty-string? string?)
  (compile/bytes (string->bytes/utf-8 data)))


(module+ test
  (require rackunit)

  (test-case "can compile SCSS files to CSS"
    (define output
      (compile/file "resources/test.scss"))

    (define expected #<<STYLE
body {
  color: #fff; }

STYLE
      )

    (check-equal? output expected))

  (test-case "can compile SCSS strings to CSS"
    (define output
      (compile/string #<<STYLE
$primary: red;

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  color: $primary;
}
STYLE
                      ))

    (define expected #<<STYLE
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box; }

body {
  color: red; }

STYLE
      )

    (check-equal? output expected))

  (test-case "handles exceptions"
    (check-exn
     (lambda (e)
       (and (exn:fail:sass? e)
            (check-equal? (exn-message e) #<<MESSAGE
Error: Invalid CSS after "a {": expected "}", was ""
        on line 1:3 of stdin
>> a {
   --^

MESSAGE
                          )))
     (lambda _
       (compile/string "a {")))))
