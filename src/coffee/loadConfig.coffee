#### LoadConfig(path)
# Loads Configuration at given path and processes it's Directives
ezcake::loadConfig = (p, cB)->
  @fs.exists p, (bool)=>
    return @warn "config file #{p} was not found" if !bool
    # import data from file
    callBack = (d)=> 
      @config.require_tree.off 'changed'
      cB()
    @config.require_tree.on 'changed', callBack
    @config.require_tree.addTree p
ezcake::selectedConfig = ->
  @config.templates.configurations[@CONFIG]
ezcake::getConfigurations = ->
  @_.pluck 'name', @config.templates.configurations