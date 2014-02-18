#### log(message)
# writes message to stdout
ezcake.strings =
  hash:   '#'
  red:    '\u001b[31m'
  green:  '\u001b[32m'
  yellow: '\u001b[33m'
  reset:  '\u001b[0m'
ezcake.log = (m)->
  process.stdout.write "#{m}\n"
#### warn(message)
# writes message to stdout with warning text and colors
ezcake.warn = (m)->
  process.stdout.write "#{ezcake.strings.yellow}#{m}#{ezcake.strings.reset}\n"
#### error(message)
# writes error to stderr and terminates execution
ezcake.error = (m)->
  process.stderr.write "#{ezcake.strings.red}Error: #{m}#{ezcake.strings.reset}\n"
  process.exit 1