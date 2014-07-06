## Processor
# Utilities to process Configuration Data
class Processor
  constructor:(@selectedConfig)->
  hasDependencies: ->
    delete (config = _.clone @selectedConfig).options
    missing = []
    _.each _.flatten(_.compact(_.pluck _.compact( _.flatten config ),  'dependencies')), (val,key)=>
      missing.push val.name if !(_.findWhere _.compact( _.flatten config ), name:val.name)
    if missing.length then missing else false
  ## getModCommands
  # returns concatenated array of Modules and Commands
  getModCommands: -> @selectedConfig.modules.concat @selectedConfig.commands
  ## getRequires
  # returns array of Required Software Packages
  getRequires: ->
    # _.compact(_.pluck(@getModCommands().concat(@selectedConfig.tasks, @selectedConfig.helpers), 'requires')
    arr = _.flatten _.compact _.map @selectedConfig, (v)=> if (a = _.compact _.pluck v, 'requires').length then a else null
    _.map (_.reject arr, (obj,key,list) =>
      # return compacted test results
      !(ezcake.utils.is_intrinsic obj.name) or _.compact( _.map list.slice(key+1, list.length), (v,k) => true if _.isEqual obj, v).length > 0
    ), (o) =>     
      # set type to NPM if not defined
      o.type ?= 'npm'
      o
  ## getDependencies
  # returns array of Required EzCake Elements
  getDependencies: ->
    _.compact _.map @selectedConfig.modules, (v,k)->
      name = v.installer_options?.alias || v.name
      return null if (!v.installer or v.installer == 'npm') and ezcake.utils.is_intrinsic name
      {
        type: v.installer || 'npm'
        name: name
        version: v.installer_options?.version || '*'
        development: v.installer_options?.development || false
      }
  ## getPaths
  # returns Paths to be created in project
  getPaths: -> 
    paths = {}
    _.each (@getModCommands().concat @selectedConfig.tasks), (v,k)->
      paths[v.name] = v.paths if v.paths?
    paths
  getFiles: ->
    files = {}
    _.each @getModCommands(), (v,k)->
      files[v.name] = v.files if v.files?
    files
  ## getExts
  # returns defined file extensions for change monitoring
  getExts: ->
    (_.compact _.pluck @selectedConfig.modules, 'ext').join '|'
  ## getInvocations
  # returns array of Command Invocations
  getInvocations: ->
    _.filter @getModCommands(), (o)-> o.invocations?
  ## getCallbacks
  # returns array of defined feature-specific CallBacks
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
  ## processTasks
  # combines defined commands to be performed in task body
  processTasks: ->
    m = @getInvocations()
    _.each @selectedConfig.tasks, (v,k)=> 
      name = "on#{v.name.charAt(0).toUpperCase()}#{v.name.slice 1}"
      @selectedConfig.tasks[k].invocations = []
      _.each m, (fV,fK)=>
        _.each _.filter(fV.invocations, (o)=> o.call == name), (iV,iK)=>
          callback = "on#{fV.callback.charAt(0).toUpperCase()}#{fV.callback.slice 1}" if fV.callback
          @selectedConfig.tasks[k].invocations.push callee:fV.name, body:iV.body, callback:callback || null if iV.body.length
  ## getDeclarations
  # combines defined commands to be performed in task body
  getDeclarations: ->
    src = ""
    _.each @selectedConfig.declarations, (v,k)=>
      src = "#{src}\n\n#{@template (path.join @module_path, 'templates/_declaration.template.txt'), v}"
    src
  ## generateConfiguration
  # returns Object ready for insertion into Cakefile template
  generateConfiguration:->
    if (bundles = @selectedConfig.bundles)?
      _.each bundles, (v,k)=>
        console.log "bundle name: #{v.name}"
        if cmd[v.name]
          _.each v, (bV, bK) =>
            console.log "bK: #{bK}"
            if !(typeof bV == 'string')
              if bK != 'templates'
                console.log "bK: #{bK}"
                @selectedConfig[bK] ?= []
                if _.isArray bV
                  _.each bV, (nV,nK) => @selectedConfig[bK].push nV if nV.name? and nV.name != ""
                else
                  if ezcake.utils.is_config_element bK
                    _.each bV, (nV,nK) => @selectedConfig[bK].push nV if nV.name? and nV.name != ""
                  else
                     @selectedConfig[bK].push bV if bV.name? and bV.name != ""
              else
                (m = {})[v.name] = bV
                @selectedConfig[bK] = _.extend( @selectedConfig[bK] || {}, m ) if _.isObject bV
    @processTasks()
    ezcake.error "missing the following dependiences: #{deps}" if deps = @hasDependencies()
    _.extend @selectedConfig, {
      reqs: (reqs = _.where @getRequires(), type:'npm')
      version: @version
      paths:@getPaths()
      exts: @getExts()
      callbacks: @getCallbacks()
      options: @selectedConfig.options || []
      templates:JSON.stringify @selectedConfig.templates || {}, null, 2
    }