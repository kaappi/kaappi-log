(import (scheme base) (scheme write)
        (kaappi log))

(define pass 0)
(define fail 0)

(define-syntax check
  (syntax-rules (=>)
    ((_ expr => expected)
     (let ((result expr) (exp expected))
       (if (equal? result exp)
           (set! pass (+ pass 1))
           (begin
             (set! fail (+ fail 1))
             (display "FAIL: ") (write 'expr)
             (display " => ") (write result)
             (display ", expected ") (write exp)
             (newline)))))))

(define-syntax check-true
  (syntax-rules ()
    ((_ expr)
     (if expr (set! pass (+ pass 1))
         (begin (set! fail (+ fail 1))
                (display "FAIL: ") (write 'expr)
                (display " is false\n"))))))

(define (capture-log thunk)
  (let ((port (open-output-string)))
    (log-set-port! port)
    (thunk)
    (log-set-port! (current-error-port))
    (get-output-string port)))

(define (str-contains? haystack needle)
  (let ((hlen (string-length haystack))
        (nlen (string-length needle)))
    (let loop ((i 0))
      (cond
        ((> (+ i nlen) hlen) #f)
        ((string=? (substring haystack i (+ i nlen)) needle) #t)
        (else (loop (+ i 1)))))))

;; --- Basic levels ---

(display "Log levels\n")

(let ((out (capture-log (lambda () (log-info "hello")))))
  (check-true (str-contains? out "[INFO]"))
  (check-true (str-contains? out "hello")))

(let ((out (capture-log (lambda () (log-warn "caution")))))
  (check-true (str-contains? out "[WARN]"))
  (check-true (str-contains? out "caution")))

(let ((out (capture-log (lambda () (log-error "bad")))))
  (check-true (str-contains? out "[ERROR]")))

;; --- Level filtering ---

(display "Level filtering\n")

(log-set-level! LOG-WARN)
(let ((out (capture-log (lambda () (log-info "hidden")))))
  (check (string-length out) => 0))

(let ((out (capture-log (lambda () (log-warn "shown")))))
  (check-true (> (string-length out) 0)))

(log-set-level! LOG-DEBUG)
(let ((out (capture-log (lambda () (log-debug "verbose")))))
  (check-true (str-contains? out "[DEBUG]")))

(log-set-level! LOG-INFO)

;; --- Structured fields ---

(display "Structured fields\n")

(let ((out (capture-log
            (lambda ()
              (log-info "request" '("method" . "GET") '("path" . "/api"))))))
  (check-true (str-contains? out "method=GET"))
  (check-true (str-contains? out "path=/api")))

;; --- JSON format ---

(display "JSON format\n")

(log-set-format! 'json)
(let ((out (capture-log
            (lambda ()
              (log-info "event" '("user" . "alice") '("code" . 200))))))
  (check-true (str-contains? out "\"level\":\"INFO\""))
  (check-true (str-contains? out "\"msg\":\"event\""))
  (check-true (str-contains? out "\"user\":\"alice\""))
  (check-true (str-contains? out "\"code\":200")))

(log-set-format! 'text)

;; --- Context fields ---

(display "Context fields\n")

(let ((out (capture-log
            (lambda ()
              (log-with-fields '(("req_id" . "abc123"))
                (lambda ()
                  (log-info "processing")))))))
  (check-true (str-contains? out "req_id=abc123")))

;; --- Summary ---

(newline)
(display pass) (display " passed, ")
(display fail) (display " failed\n")
(when (> fail 0) (exit 1))
