# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

## [0.1.0] - 2026-07-26

### Added
- Structured logging — `log-debug`/`log-info`/`log-warn`/`log-error`/`log-fatal`
  with configurable level, output port, and format
  (`log-set-level!`/`log-set-port!`/`log-set-format!`), and structured field
  context via `log-with-fields`
- Pure Scheme implementation, no C dependencies or build step
- CI workflow for automated testing
