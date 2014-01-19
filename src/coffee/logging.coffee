#### log(message)
# writes message to stdout
ezcake::log = (m)->
  process.stdout.write "#{m}\n"
#### warn(message)
# writes message to stdout with warning text and colors
ezcake::warn = (m)->
  process.stdout.write "#{@strings.yellow}Warning: #{m}#{@strings.reset}\n"
#### error(message)
# writes error to stderr and terminates execution
ezcake::error = (m)->
  process.stderr.write "#{@strings.red}Error: #{m}#{@strings.reset}\n"
  process.exit 1