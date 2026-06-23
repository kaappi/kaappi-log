# kaappi-log

Structured logging library for [Kaappi Scheme](https://github.com/kaappi/kaappi).

Pure Scheme — no C dependencies, no build step.

## Install

```bash
thottam install kaappi-log
```

## Quick start

```scheme
(import (kaappi log))

(log-info "server started" '("port" . 8080))
;=> 1719100000 [INFO] server started port=8080

(log-error "failed" '("code" . 500) '("path" . "/api"))
;=> 1719100000 [ERROR] failed code=500 path=/api
```

## API

### Log functions

```scheme
(log-debug msg field ...)    ; DEBUG level
(log-info msg field ...)     ; INFO level
(log-warn msg field ...)     ; WARN level
(log-error msg field ...)    ; ERROR level
(log-fatal msg field ...)    ; FATAL level
```

Fields are pairs: `'("key" . value)`. Values can be strings, numbers, or booleans.

### Configuration

```scheme
(log-set-level! LOG-WARN)          ; suppress DEBUG and INFO
(log-set-port! (current-output-port))  ; log to stdout
(log-set-format! 'json)           ; JSON output
(log-set-format! 'text)           ; text output (default)
```

### Context fields

```scheme
(log-with-fields '(("req_id" . "abc123"))
  (lambda ()
    (log-info "processing")    ; includes req_id=abc123
    (log-info "done")))        ; includes req_id=abc123
```

## Output formats

### Text (default)

```
1719100000 [INFO] request method=GET path=/api status=200
```

### JSON

```json
{"time":"1719100000","level":"INFO","msg":"request","method":"GET","path":"/api","status":200}
```

## Log levels

| Level | Constant | Value |
|-------|----------|-------|
| DEBUG | `LOG-DEBUG` | 0 |
| INFO  | `LOG-INFO`  | 1 |
| WARN  | `LOG-WARN`  | 2 |
| ERROR | `LOG-ERROR` | 3 |
| FATAL | `LOG-FATAL` | 4 |

## License

MIT
