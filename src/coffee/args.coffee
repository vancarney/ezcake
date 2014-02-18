#### void preprocessArgs()
# validate `process.argv` ezcake.COMMANDModuleArray and set variables based on it's content
ezcake::preProcessArgs = (callback)->
  args = []
  _.each process.argv, (v,k) => args.push v if (v.match /^(\-h|\-\-help)+$/) == null
  cmd.parse args
  callback null
#### void processArgs()
# validate `process.argv` ezcake.COMMANDModuleArray and set variables based on it's content
ezcake::processArgs = (cB)->
  # force help for invalid command format
  if process.argv.length <3
    process.argv.push '-h'
  else
    # we loop through argv and set some variables for reference
    process.argv.forEach (val, index)=>
      # `ezcake.ENV` tells us it's Node
      return (ezcake.ENV = val)           if index == 0
      # `ezcake.PATH` tells us our current working directory
      return (ezcake.PATH = val)          if index == 1
      # `ezcake.COMMAND` should be one of `create` or `init` or one of their aliases
      return (ezcake.COMMAND = val)       if index == 2 && (typeof ezcake.COMMAND == 'undefined') && !(val.match /^\-/)
      # `ezcake.CONFIGuration` should map to a valid `ezcake.json` configuration directive
      return (ezcake.CONFIG = val)        if index == 3 && (ezcake.COMMAND.match /create|init/) && !(val.match /^\-/)
      # ``ezcake.NAME` is the directory name to be created and only applicable for `create`
      return (ezcake.NAME = val)          if index == 4 && (ezcake.COMMAND.match /create/) && !(val.match /^\-/)
   cB()
#### processConfiguration
ezcake::processConfiguration = (cB)->
  return ezcake.error 'No Configurations loaded' if !(configs = @configs.getConfigurations())
  # process our configuration
  if typeof _.findWhere(configs, name:ezcake.CONFIG) != 'undefined'
    # add no-config to Commander options
    cmd.option "-F, --no-config", "Do not create ezcake config file"
    cB()
  else
    ezcake.error "Configuration '#{ezcake.CONFIG}' was not found"