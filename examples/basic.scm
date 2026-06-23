(import (kaappi log))

(log-info "server started" '("port" . 8080))
(log-debug "loading config" '("file" . "app.toml"))
(log-info "request" '("method" . "GET") '("path" . "/api/users") '("status" . 200))
(log-warn "slow query" '("ms" . 1523) '("table" . "users"))
(log-error "connection failed" '("host" . "db.local") '("retry" . 3))

(newline)
(display "--- JSON format ---\n")
(log-set-format! 'json)
(log-info "request" '("method" . "POST") '("path" . "/api/login") '("status" . 401))
(log-error "auth failed" '("user" . "alice"))
