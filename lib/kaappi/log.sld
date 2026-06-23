(define-library (kaappi log)
  (import (scheme base) (scheme write) (scheme time))
  (export log-debug log-info log-warn log-error log-fatal
          log-set-level! log-set-port! log-set-format!
          log-with-fields
          LOG-DEBUG LOG-INFO LOG-WARN LOG-ERROR LOG-FATAL)
  (begin

    (define LOG-DEBUG 0)
    (define LOG-INFO  1)
    (define LOG-WARN  2)
    (define LOG-ERROR 3)
    (define LOG-FATAL 4)

    (define %level LOG-INFO)
    (define %port (current-error-port))
    (define %format 'text)
    (define %fields '())

    (define (log-set-level! level) (set! %level level))
    (define (log-set-port! port) (set! %port port))
    (define (log-set-format! fmt) (set! %format fmt))

    (define (log-with-fields fields thunk)
      (let ((old %fields))
        (set! %fields (append fields old))
        (thunk)
        (set! %fields old)))

    (define (level-name level)
      (cond
        ((= level LOG-DEBUG) "DEBUG")
        ((= level LOG-INFO)  "INFO")
        ((= level LOG-WARN)  "WARN")
        ((= level LOG-ERROR) "ERROR")
        ((= level LOG-FATAL) "FATAL")
        (else "???")))

    (define (emit level msg fields)
      (when (>= level %level)
        (let ((all-fields (append fields %fields)))
          (if (eq? %format 'json)
              (emit-json level msg all-fields)
              (emit-text level msg all-fields)))))

    (define (emit-text level msg fields)
      (let ((ts (timestamp)))
        (write-string ts %port)
        (write-string " [" %port)
        (write-string (level-name level) %port)
        (write-string "] " %port)
        (write-string msg %port)
        (emit-text-fields fields)
        (newline %port)))

    (define (emit-text-fields fields)
      (let loop ((fs fields))
        (when (pair? fs)
          (write-string " " %port)
          (write-string (caar fs) %port)
          (write-string "=" %port)
          (write-field-value (cdar fs))
          (loop (cdr fs)))))

    (define (emit-json level msg fields)
      (write-string "{\"time\":\"" %port)
      (write-string (timestamp) %port)
      (write-string "\",\"level\":\"" %port)
      (write-string (level-name level) %port)
      (write-string "\",\"msg\":\"" %port)
      (write-json-escaped msg %port)
      (write-string "\"" %port)
      (let loop ((fs fields))
        (when (pair? fs)
          (write-string ",\"" %port)
          (write-json-escaped (caar fs) %port)
          (write-string "\":" %port)
          (write-json-value (cdar fs) %port)
          (loop (cdr fs))))
      (write-string "}" %port)
      (newline %port))

    (define (write-field-value val)
      (cond
        ((string? val) (write-string val %port))
        ((number? val) (write-string (number->string val) %port))
        ((boolean? val) (write-string (if val "true" "false") %port))
        (else (write val %port))))

    (define (write-json-value val port)
      (cond
        ((string? val)
         (write-string "\"" port)
         (write-json-escaped val port)
         (write-string "\"" port))
        ((number? val) (write-string (number->string val) port))
        ((boolean? val) (write-string (if val "true" "false") port))
        ((eq? val 'null) (write-string "null" port))
        (else (write-string "\"" port) (write val port)
              (write-string "\"" port))))

    (define (write-json-escaped s port)
      (let loop ((i 0))
        (when (< i (string-length s))
          (let ((ch (string-ref s i)))
            (cond
              ((char=? ch #\\) (write-string "\\\\" port))
              ((char=? ch #\") (write-string "\\\"" port))
              ((char=? ch #\newline) (write-string "\\n" port))
              ((char=? ch #\return) (write-string "\\r" port))
              ((char=? ch #\tab) (write-string "\\t" port))
              (else (write-char ch port))))
          (loop (+ i 1)))))

    (define (timestamp)
      (let* ((secs (exact (truncate (current-second))))
             (s (number->string secs)))
        s))

    ;; Public logging functions

    (define (log-debug msg . fields)
      (emit LOG-DEBUG msg fields))

    (define (log-info msg . fields)
      (emit LOG-INFO msg fields))

    (define (log-warn msg . fields)
      (emit LOG-WARN msg fields))

    (define (log-error msg . fields)
      (emit LOG-ERROR msg fields))

    (define (log-fatal msg . fields)
      (emit LOG-FATAL msg fields))))
