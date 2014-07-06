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
      #-- ezcake.utils.replaceAll val, {c:'create', u:'update', l:'list', p:'publish', x:'unpublish'}
      return (ezcake.COMMAND = val) if index == 2 && (typeof ezcake.COMMAND == 'undefined') && !(val.match /^\-/)
      # `ezcake.CONFIGuration` should map to a valid `ezcake.json` configuration directive
      return (ezcake.CONFIG = val) if index == 3 && (ezcake.COMMAND.match /create|update|list|install|uninstall/) && !(val.match /^\-/)
      return (ezcake.PATH   = val) if index == 3 && (ezcake.COMMAND.match /publish|unpublish/) && !(val.match /^\-/)
      # ``ezcake.NAME` is the directory name to be created and only applicable for `create`
      return (ezcake.NAME   = val) if index == 4 && (ezcake.COMMAND.match /create/) && !(val.match /^\-/)
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
#### loadConfiguration
ezcake::loadConfiguration = (p, cB)->
  keys = [ 'bundles','commands', 'helpers', 'cake_template', 'modules', 'options', 'tasks', 'paths', 'templates' ]
  (loader = new ConfigLoader()).loadConfig path.normalize(p), =>
    config   = _.clone loader.__loader[loader.__loader.require_tree.loadedConfigs[0]]
    elements = @configs.__loader[@configs.__loader.require_tree.loadedConfigs[0]]
    _.each keys, (v)=>
      config[v] = _.find elements, (idx, o)=> v.lastIndexOf o.name > -1
    data = "#{JSON.stringify config}\n"
    opts =
      hostname: '0.0.0.0'
      port: 3000
      path: '/api'
      method: 'POST'
      headers:
        'Content-Type': 'application/json'
        'Content-Length': data.length
    req = http.request opts, (res)->
      res.setEncoding 'utf8'
      console.log "STATUS: #{res.statusCode}"
      console.log "HEADERS: #{JSON.stringify res.headers}"
      res.on 'data', (chunk)-> console.log chunk
    req.write data
    req.end()
      
