class Processor
  constructor:(@selectedConfig)->
  hasDependencies: ->
    has = _.every _.flatten(_.pluck @selectedConfig,  "required"), (val)=>
      (_.find (_.pluck _.extend( {}, @declarations, @helpers, @selectedConfig.modules), "name"), (n)=>
        n == val
      ) || false
    throw new Error "'#{val}' was required but not found" if not has
    true
  getModCommands: -> @selectedConfig.modules.concat @selectedConfig.commands
  getRequires: ->
    arr = _.flatten _.compact _.map @selectedConfig, (v)=> if (a = _.compact _.pluck v, 'requires').length then a else null
    _.map (_.reject arr, (obj,key,list) =>
      # return compacted test results
      _.compact( _.map list.slice(key+1, list.length), (v,k) => true if _.isEqual obj, v).length > 0
    ), (o) =>     
      # set type to NPM if not defined
      o.type ?= 'npm'
      o
  getDependencies: ->
    _.map @selectedConfig.modules, (v,k)->
      {
        type: v.installer || 'npm'
        name: v.installer_options?.alias || v.name
        version: v.installer_options?.version || '*'
        development: v.installer_options?.development || false
      }
  getPaths: (data)-> 
    paths = {}
    _.each data, (v,k)-> 
      paths[v.name] = v.paths if v.paths?
    JSON.stringify paths, null, 2
  getExts: ->
    (_.compact _.pluck @selectedConfig.modules, 'ext').join '|'
  getInvocations: ->
    _.filter @getModCommands(), (o)-> o.invocations?
  getCallbacks: ->
    mC = @getModCommands()
    callbacks = []
    _.each (_.map (_.compact _.pluck mC, 'callback'), (v,k)-> 
      name:"on#{v.charAt(0).toUpperCase()}#{v.slice 1}", invocations:[]
    ), (v,k)=>
      callbacks[k] = v
      _.each (_.filter mC, (o)-> o.invocations?), (fV,fK)=>
        _.each _.filter(fV.invocations, (o)=> o.call == v.name), (iV,iK)=>
          callbacks[k].invocations.push callee:fV.name, body:iV.body
    callbacks
  processTasks: ->
    m = @getInvocations()
    _.each @selectedConfig.tasks, (v,k)=> 
      name = "on#{v.name.charAt(0).toUpperCase()}#{v.name.slice 1}"
      @selectedConfig.tasks[k].invocations = []
      _.each m, (fV,fK)=>
        _.each _.filter(fV.invocations, (o)=> o.call == name), (iV,iK)=>
          @selectedConfig.tasks[k].invocations.push callee:fV.name, body:iV.body if iV.body.length
  getDeclarations: ->
    src = ""
    _.each @selectedConfig.declarations, (v,k)=>
     src = "#{src}\n\n#{@template (path.join @module_path, 'templates/_declaration.template.txt'), v}"
     # console.log "src: #{src}"
    src
  getHelpers: ->
    (_.map ezcake.CONFIG.default.helpers, (v,k)=>
      @template "#{path.join @module_path, 'templates/_helper.template.txt'}", v
    ).join "\n"

  generateConfiguration:->
    if (bundles = @selectedConfig.bundles)?
      _.each bundles, (v,k)=>
        if cmd[v.name]
          _.each v, (bV, bK) =>
            if bK != 'templates' 
              selected[bK] = _.union( selected[bK] || [], bV) if _.isObject bV 
            else
              (m = {})[v.name] = bV
              selected[bK] = _.extend( selected[bK] || {}, m ) if _.isObject bV
    @processTasks()
    _.extend @selectedConfig, {
      reqs: (reqs = _.where @getRequires(), type:'npm')
      version: @version
      paths:@getPaths @getModCommands()
      exts: @getExts()
      callbacks: @getCallbacks()
      options: @selectedConfig.options || []
      templates:JSON.stringify @selectedConfig.templates || {}, null, 2
    }