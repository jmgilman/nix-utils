# Logs a message at INFO level
def debug [
  msg: string  # The message to log
] {
  print $"(ansi c)[DEBUG] >>> ($msg)(ansi reset)"
}

# Logs a message at INFO level
def info [
  msg: string  # The message to log
] {
  print $"(ansi g)[INFO]  >>> ($msg)(ansi reset)"
}

# Logs a message at WARN level
def warn [
  msg: string  # The message to log
] {
  print $"(ansi y)[WARN] >>> ($msg)(ansi reset)"
}

# Logs a message at ERROR level
def error [
  msg: string  # The message to log
] {
  print $"(ansi r)[ERROR] >>> ($msg)(ansi reset)"
}

# Logs a message at ERROR level and exits
def fatal [
  msg: string  # The message to log
] {
  error $msg
  exit 1
}