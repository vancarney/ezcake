#### LoadConfig(path)
# Loads Configuration at given path and processes it's Directives
ezcake::loadConfig = (p, cB)->
  fs.exists p, (bool)=>
    return @warn "config file #{p} was not found" if !bool
    addPath = p.split(path.sep).pop()
    # import data from file
    callBack = (d)=>
      if _.isArray c=@config.require_tree.loadedConfigs
        @config.require_tree.loadedConfigs.push addPath 
      else
        @config.require_tree.loadedConfigs = [addPath]
      @config.require_tree.off 'changed' 
      cB()
    @config.require_tree.on 'changed', callBack
    @config.require_tree.addTree p
ezcake::extendConfigurations = ->
  _.each @uConfig.configurations, (v,k)=>
    @uConfig.configurations[k] = _.extend _.clone(x), v if v.inherits? and (x = _.findWhere @uConfig.configurations, name:v.inherits)?
ezcake::selectedConfig = ->
  conf = {}
  _.each _.keys(c = _.findWhere @uConfig.configurations, name:@CONFIG), (v,k)=>
    conf[v] = _.map @uConfig[v], (cV,cK) => cV
  conf = _.extend conf,
    bundles: _.filter @uConfig.bundles, (o)=> _.contains c.bundles, o.name
    modules: _.filter @uConfig.modules, (o)=> _.contains c.modules, o.name 
    tasks: _.filter @uConfig.tasks, (o)=> _.contains c.tasks, o.name
    declarations: @uConfig.declarations
    helpers: @uConfig.helpers
ezcake::mergeConfigs = (cB)->
  # console.log JSON.stringify @config, null, 2
  # Loops through loadedConfig Names Array (reversed if 'no-overrides' is passed)
  _.each (if cmd['override'] then @config.require_tree.loadedConfigs else @config.require_tree.loadedConfigs.reverse()), (v,k)=>
    # Finds each package
    _.each (pkg = @config.require_tree.getPackage v), (oV,oK)=>
      # Normalize elements to be Array
      if _.isObject(pkg[oK]) and !(pkg[oK] instanceof Array)
        pkg[oK] = _.map pkg[oK], (itmV,itmK) => itmV if itmV.name?
      # Tests if Array is type Array
      if pkg[oK] instanceof Array
        # Sets @uConfig[oK] if it is undefined
        @uConfig[oK] ?= []
        # Tests if defined @uConfig[oK] is Array
        if (@uConfig[oK] instanceof Array)
          # Loops on each item in package child
          _.each pkg[oK], (itmV,itmK) =>
            # Tests to see if item exists in package child Array
            if itmV.name? and (typeof (f = _.findWhere @uConfig[oK], name:itmV.name) != 'undefined')
              # Replaces item if founds
              @uConfig[oK][_.indexOf @uConfig[oK], f] = itmV
            else
              # Pushes unique item to package child Array
              # @uConfig[oK][itmK] = _.clone itmV
              @uConfig[oK].push _.clone itmV
        else
          # Merge Child Objects if was not Array
          _.each pkg[oK], (itmV,itmK) =>
            @uConfig[oK] = _.extend @uConfig[oK] || {}, _.clone itmV if itmV.name?
      else
        # Set value as clone of Object if value was not Array
        @uConfig[oK] = if typeof pkg[oK] == 'string' then "#{pkg[oK]}" else _.extend @uConfig[oK] || {}, _.clone pkg[oK]
ezcake::getConfigurations = ->
  configs = []
  _.each @config.require_tree.loadedConfigs, (v,k)=>
    if (pkg = @config.require_tree.getPackage v)?
      configs = _.union configs, (if !(pkg.configurations instanceof Array) then _.keys pkg.configurations else _.pluck pkg.configurations, 'name')
  configs