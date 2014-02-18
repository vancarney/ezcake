class ConfigLoader
  constructor:->
    @__loader = require_tree null
    @__config = {}
  getConfigurations:-> 
      @__config.configurations
  getConfig: -> @__config
  #### LoadConfig(path)
  # Loads Configuration at given path and processes it's Directives
  loadConfig: (p, cB)->
    fs.exists p, (bool)=>
      return @warn "config file #{p} was not found" if !bool
      addPath = p.split(path.sep).pop()
      # import data from file
      callBack = (d)=>
        if _.isArray @__loader.require_tree.loadedConfigs
          @__loader.require_tree.loadedConfigs.push addPath 
        else
          @__loader.require_tree.loadedConfigs = [addPath]
        @__loader.require_tree.off 'changed' 
        cB()
      @__loader.require_tree.on 'changed', callBack
      @__loader.require_tree.addTree p
  extendConfigurations: ->
    _.each @__config.configurations, (v,k)=>
      @__config.configurations[k] = _.extend _.clone(x), v if v.inherits? and (x = _.findWhere @__config.configurations, name:v.inherits)?
  selectedConfig: ->
    conf = {}
    try
      _.each _.keys(c = _.findWhere @__config.configurations, name:ezcake.CONFIG), (v,k)=>
        conf[v] = _.map @__config[v], (cV,cK) => cV
      conf = _.extend conf,
        bundles: _.filter @__config.bundles, (o)=> _.contains c.bundles, o.name
        modules: _.filter @__config.modules, (o)=> _.contains c.modules, o.name 
        tasks: _.filter @__config.tasks, (o)=> _.contains c.tasks, o.name
        declarations: @__config.declarations
        helpers: @__config.helpers
    catch e
      ezcake.error "failed to select configuration '#{ezcake.CONFIG}'. [#{e}]"
  mergeConfigs: (cB)->
    # console.log JSON.stringify @__loader, null, 2
    # Loops through loadedConfig Names Array (reversed if 'no-overrides' is passed)
    _.each (if cmd['override'] then @__loader.require_tree.loadedConfigs else @__loader.require_tree.loadedConfigs.reverse()), (v,k)=>
      # Finds each package
      _.each (pkg = @__loader.require_tree.getPackage v), (oV,oK)=>
        # Normalize elements to be Array
        if _.isObject(pkg[oK]) and !(pkg[oK] instanceof Array)
          pkg[oK] = _.map pkg[oK], (itmV,itmK) => itmV if itmV.name?
        # Tests if Array is type Array
        if pkg[oK] instanceof Array
          # Sets @__config[oK] if it is undefined
          @__config[oK] ?= []
          # Tests if defined @__config[oK] is Array
          if (@__config[oK] instanceof Array)
            # Loops on each item in package child
            _.each pkg[oK], (itmV,itmK) =>
              # Tests to see if item exists in package child Array
              if itmV.name? and (typeof (f = _.findWhere @__config[oK], name:itmV.name) != 'undefined')
                # Replaces item if founds
                @__config[oK][_.indexOf @__config[oK], f] = itmV
              else
                # Pushes unique item to package child Array
                # @__config[oK][itmK] = _.clone itmV
                @__config[oK].push _.clone itmV
          else
            # Merge Child Objects if was not Array
            _.each pkg[oK], (itmV,itmK) =>
              @__config[oK] = _.extend @__config[oK] || {}, _.clone itmV if itmV.name?
        else
          # Set value as clone of Object if value was not Array
          @__config[oK] = if typeof pkg[oK] == 'string' then "#{pkg[oK]}" else _.extend @__config[oK] || {}, _.clone pkg[oK]
  listConfigurations: ->
    configs = []
    _.each @__loader.require_tree.loadedConfigs, (v,k)=>
      if (pkg = @__loader.require_tree.getPackage v)?
        configs = _.union configs, (if !(pkg.configurations instanceof Array) then _.keys pkg.configurations else _.pluck pkg.configurations, 'name')
    configs