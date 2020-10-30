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

(define/contract current-include-paths
  (parameter/c (listof path-string?))
  (make-parameter null))

(define (prepare-context! context)
  (define options (sass_context_get_options context))
  (for ([path (reverse (current-include-paths))])
    ;; Unlike sass_make_data_context, this function does not take
    ;; ownership of path.  Cool.
    (sass_option_push_include_path options (path->complete-path path))))

(define ((make-compiler #:constructor make-wrapper
                        #:destructor free-wrapper
                        #:context-accessor get-context
                        #:compilation-fn compile-sass) input)
  (define wrapper #f)
  (define context #f)

  (dynamic-wind
    (lambda _
      (set! wrapper (make-wrapper input))
      (set! context (get-context wrapper))
      (prepare-context! context))
    (lambda _
      (define code (compile-sass wrapper))
      (case code
        [(0) (sass_context_get_output_string context)]
        [else (raise-context-error context code)]))
    (lambda _
      (free-wrapper wrapper))))

(define/contract compile/file
  (-> path-string? string?)
  (make-compiler #:constructor (compose1 sass_make_file_context path->complete-path)
                 #:destructor sass_delete_file_context
                 #:context-accessor sass_file_context_get_context
                 #:compilation-fn sass_compile_file_context))

(define/contract compile/bytes
  (-> bytes? string?)
  ;; Sass_Data_Context frees the string that gets passed into it after
  ;; compilation so we have to copy the input string and ensure that the
  ;; resulting copy isn't managed by the GC.
  (make-compiler #:constructor (compose1 sass_make_data_context bytes->unmanaged-cstring)
                 #:destructor sass_delete_data_context
                 #:context-accessor sass_data_context_get_context
                 #:compilation-fn sass_compile_data_context))

(define/contract (compile/string data)
  (-> non-empty-string? string?)
  (compile/bytes (string->bytes/utf-8 data)))


(module+ test
  (require rackunit)

  (define (normalize-line-endings s)
    (string-replace s "\r" ""))

  (define-check (check-normalized-string= a b)
    (unless (string=? (normalize-line-endings a)
                      (normalize-line-endings b))
      (fail-check)))

  (test-case "can compile SCSS files to CSS"
    (define output
      (compile/file "resources/test.scss"))

    (define expected #<<STYLE
body {
  color: #fff; }

STYLE
      )

    (check-normalized-string= output expected))

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

    (check-normalized-string= output expected))

  (test-case "can include files off the include path"
    (define output
      (parameterize ([current-include-paths '("resources/include")])
        (compile/string #<<STYLE
@import "_reset.scss";
STYLE
                        )))

    (define expected #<<STYLE
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box; }

STYLE
      )

    (check-normalized-string= output expected))

  (test-case "raises an exception when an included file can't be found on the path"
    (check-exn
     (lambda (e)
       (and (exn:fail:sass? e)
            (check-regexp-match #rx"File to import not found or unreadable" (exn-message e))))
     (lambda _
       (compile/string "@import '_reset.scss';"))))

  (test-case "raises an exception on parse error"
    (check-exn
     (lambda (e)
       (and (exn:fail:sass? e)
            (check-normalized-string= (exn-message e) #<<MESSAGE
Error: Invalid CSS after "a {": expected "}", was ""
        on line 1:3 of stdin
>> a {
   --^

MESSAGE
                          )))
     (lambda _
       (compile/string "a {")))))
