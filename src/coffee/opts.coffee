#### createOpts()
# Initializes Commander Options
ezcake::createOpts = (cB)->
  # requires [Commander.js](https://github.com/visionmedia/commander.js)
  cmd.version( "version: #{@version}"
  # set Option 'Ignore'
  ).option( "-I, --ignore", "ignore global config file if defined in env.EZCAKE_HOME"
  # set Option 'No Override'
  ).option( "-O, --no-override", "do not allow loaded configs to override each other"
  # set Option 'Location'
  ).option  "-l, --location <paths>", "set path(s) of config file location(s)", (arg)->arg.split ','
  cB()
#### getOpts()
# retrieves Options from current configuration's Modules and Commands
ezcake::getOpts = (cB)->
  cnf = @configs.selectedConfig()
  # console.log @uConfig.bundles
  _.each (ezcake.COMMANDModuleArr=[].concat cnf.modules || [], cnf.commands || [], cnf.bundles || []), (v,k)=>
    if (t = _.findWhere ([].concat (c=@configs.getConfig()).modules, c.commands, c.bundles), name:v.name)?
      # console.log JSON.stringify t, null, 2
      if t.command? and t.command instanceof Array and t.command.length > 1
        # load the command value into Commander
        cmd.option t.command[0], t.command[1]
      else
        return ezcake.error "command element for config #{cnf.name} was #{if typeof t.command == 'undefined' then 'missing' else 'malformed'}" 
      if (_.indexOf t.command[1]) > -1 || process.argv[process.argv.length - 1].match new RegExp "[#{t.command[0].charAt 1}]+"
        process.argv.push t.setFlag if typeof t.setFlag != 'undefined' && t.setFlag?
    else
      ezcake.error "#{v.name || 'object'} was not defined"
  cB()
#### help()
# adds a help flag to argv to trigger help output from Commander
ezcake::help = ->
  (process.argv.splice 2, idx-2) if (idx = process.argv.indexOf '-h') > -1