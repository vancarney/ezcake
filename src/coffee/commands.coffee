#### onCreate
# handler for `create` command
ezcake::onCreate = ->
  @usage="""create #{ezcake.CONFIG or '<type>'} <name> [options]
  
    Creates new #{ezcake.CONFIG or '<type>'} configuration as directory <name> in current path
  """
  @usage += "\n  Available types: #{@configs.listConfigurations().join ', '}" if typeof ezcake.CONFIG == 'undefined'
  if (typeof ezcake.NAME != 'undefined') then @$path +="/#{ezcake.NAME}" else process.argv.push '-h'
#### onUpdate
# handles `update` command
ezcake::onUpdate = ->
  @usage="""update #{ezcake.CONFIG or '<type>'} [options]
  
    Creates or Updates #{ezcake.CONFIG or '<type>'} Cakefile in current Project Directory
  """
  @usage += "\n  Available types: #{configs.listConfigurations().join ', '}" if typeof ezcake.CONFIG == 'undefined'
  @success = "Cakefile updated!\n"
#### onList
# handles `list` command
ezcake::onList = ->
  @usage="""list [type] [options]
  
    Lists available ezcake elements in ezcake load paths
  """
  @success = "\n"
#### onSearch
# handles `search` command
ezcake::onSearch = ->
  @usage="""search [name] [options]
  
    Search for ezcake elements on ezcake.co
  """
  @success = "\n"
#### onPublish
# handles `publish` command
ezcake::onPublish = ->
  @usage="""publish #{ezcake.PATH || '<path>'} [options]
  
    Publish to ezcake.co
  """
  @success = "#{ezcake.PATH} published\n"
#### onPublish
# handles `publish` command
ezcake::onUnpublish = ->
  @usage="""unpublish #{ezcake.PATH || '<path>'} [options]
  
    unpublishes config from ezcake.co
  """
  @success = "#{ezcake.PATH} unpublished\n"
#### onPublish
# handles `publish` command
ezcake::onInstall = ->
  @usage="""install #{ezcake.CONFIG || '<config>'} [options]
  
    install configuration from ezcake.co
  """
  @success = "#{ezcake.CONFIG} installed\n"
#### onPublish
# handles `publish` command
ezcake::onUninstall = ->
  @usage="""uninstall #{ezcake.CONFIG || '<config>'} [options]
  
    uninstall configuration from ezcake.co
  """
  @success = "#{ezcake.CONFIG} uninstall\n"