#### onCreate
# handles create command
ezcake::onCreate = ->
  @usage="""create #{ezcake.CONFIG or '<type>'} <name> [options]
  
    Creates new #{ezcake.CONFIG or '<type>'} configuration as directory <name> in current path
  """
  @usage += "\n  Available types: #{@configs.listConfigurations().join ', '}" if typeof ezcake.CONFIG == 'undefined'
  if (typeof ezcake.NAME != 'undefined') then @$path +="/#{ezcake.NAME}" else process.argv.push '-h'
  fs.exists @$path, (bool)=>
    if !bool
      fs.mkdir @$path, (e)=>
        ezcake.error e if e?
        @success = "#{ezcake.CONFIG} created as #{ezcake.NAME}\n"
#### onInit
# handles init command
ezcake::onInit = ->
  @usage="""init #{ezcake.CONFIG or '<type>'} [options]
  
    Creates or Updates #{ezcake.CONFIG or '<type>'} Cakefile in current Project Directory
  """
  @usage += "\n  Available types: #{configs.listConfigurations().join ', '}" if typeof ezcake.CONFIG == 'undefined'
  @success = "Cakefile updated!\n"