ezcake::createOpts = (cB)->
  # requires [Commander.js](https://github.com/visionmedia/commander.js)
  @cmd.version( 'version: #{@version}'
  # set Option 'Ignore'
  ).option( "-I, --ignore", "ignore global config file if defined in env.EZCAKE_HOME"
  # set Option 'No Override'
  ).option( "-O, --no-override", "do not allow loaded configs to override each other"
  # set Option 'Location'
  ).option  "-l, --location <paths>", "set path(s) of config file location(s)", (arg)->arg.split ','
  cB()
ezcake::getOpts = (cB)->
  @_.each (@commandModuleArr=[].concat @uConfig.modules, @uConfig.commands), (v,k)=>
    if (t = @_.findWhere ([].concat @config.templates.modules, @config.templates.commands), name:v) != undefined
      # load the command value into Commander
      @cmd.option t.command[0], t.command[1]
      if (@_.indexOf t.command[1]) > -1 || process.argv[process.argv.length - 1].match new RegExp "[#{t.command[0].charAt 1}]+"
        process.argv.push t.setFlag if typeof t.setFlag != 'undefined' && t.setFlag?
    else
      @error "#{v} was not defined"
  cB()
#### help()
# adds a help flag to argv to trigger help output from Commander
ezcake::help = ->
  (process.argv.splice 2,idx-2) if (idx = process.argv.indexOf '-h') > -1