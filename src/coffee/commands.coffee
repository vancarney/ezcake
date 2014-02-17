#### onCreate
# handles create command
ezcake::onCreate = ->
  @usage="""create #{@CONFIG or '<type>'} <name> [options]
  
    Creates new #{@CONFIG or '<type>'} configuration as directory <name> in current path
  """
  @usage += "\n  Available types: #{@getConfigurations().join ', '}" if typeof @CONFIG == 'undefined'
  if (typeof @NAME != 'undefined') then @$path +="/#{@NAME}" else process.argv.push '-h'
  fs.exists @$path, (bool)=>
    if !bool
      fs.mkdir @$path, (e)=>
        @error e if e?
        @success = "#{@CONFIG} created as #{@NAME}\n"
#### onInit
# handles init command
ezcake::onInit = ->
  @usage="""init #{@CONFIG or '<type>'} [options]
  
    Creates or Updates #{@CONFIG or '<type>'} Cakefile in current Project Directory
  """
  @usage += "\n  Available types: #{@getConfigurations().join ', '}" if typeof @CONFIG == 'undefined'
  @success = "Cakefile updated!\n"