#### void preprocessArgs()
# validate `process.argv` @commandModuleArray and set variables based on it's content
ezcake::preProcessArgs = (callback)->
  args = []
  @_.each process.argv, (v,k)=>args.push v if (v.match /^(\-h|\-\-help)+$/) == null
  @cmd.parse args
  callback null
#### void processArgs()
# validate `process.argv` @commandModuleArray and set variables based on it's content
ezcake::processArgs = (cB)->
  # force help for invalid command format
  if process.argv.length <3
    process.argv.push '-h'
  else
    # we loop through argv and set some variables for reference
    process.argv.forEach (val, index)=>
      # `@env` tells us it's Node
      return (@ENV = val)           if index == 0
      # `@path` tells us our current working directory
      return (@PATH = val)          if index == 1
      # `@command` should be one of `create` or `init` or one of their aliases
      return (@COMMAND = val)       if index == 2 && (typeof @COMMAND == 'undefined') && !(val.match /^\-/)
      # `@configuration` should map to a valid `ezcake.json` configuration directive
      return (@CONFIG = val)        if index == 3 && (@COMMAND.match /create|init/) && !(val.match /^\-/)
      # ``@name` is the directory name to be created and only applicable for `create`
      return (@NAME = val)          if index == 4 && (@COMMAND.match /create/) && !(val.match /^\-/)
   cB()
#### processConfiguration
ezcake::processConfiguration = (cB)->
  # process our configuration
  if typeof (@uConfig=@selectedConfig()) != 'undefined'
    # add no-config to Commander options
    @cmd.option "-F, --no-config", "Do not create ezcake config file"
    cB()
  else
    @error "Configuration '#{@CONFIG}' was not found"