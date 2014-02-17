ezcake::hasDependencies = ->
  has = _.every _.flatten(_.pluck @uConfigured,  "required"), (val)=>
    (_.find (_.pluck _.extend( {}, @declarations, @helpers, @uConfigured.modules), "name"), (n)=>
      n == val
    ) || false
  throw new Error "'#{val}' was required but not found" if not has
  true
  
ezcake::getModCommands = -> @uConfig.modules.concat @uConfig.commands

ezcake::getRequires = ->
  arr = _.flatten _.compact _.map @uConfig, (v)=> if (a = _.compact _.pluck v, 'requires').length then a else null
  _.map (_.reject arr, (obj,key,list) =>
    # return compacted test results
    _.compact( _.map list.slice(key+1, list.length), (v,k) => true if _.isEqual obj, v).length > 0
  ), (o) =>     
    # set type to NPM if not defined
    o.type ?= 'npm'
    o
ezcake::getDependencies = ->
  _.map @uConfig.modules, (v,k)->
    {
      type: v.installer || 'npm'
      name: v.installer_options?.alias || v.name
      version: v.installer_options?.version || '*'
      development: v.installer_options?.development || false
    }
ezcake::getPaths = (data)-> 
  paths = {}
  _.each data, (v,k)-> 
    paths[v.name] = v.paths if v.paths?
  JSON.stringify paths, null, 2
ezcake::getExts = ->
  (_.compact _.pluck @config.default.modules, 'ext').join '|'
ezcake::getInvocations = ->
  _.filter @getModCommands(), (o)-> o.invocations?
ezcake::getCallbacks = ->
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
ezcake::processTasks = ->
  m = @getInvocations()
  _.each @uConfig.tasks, (v,k)=> 
    name = "on#{v.name.charAt(0).toUpperCase()}#{v.name.slice 1}"
    @uConfig.tasks[k].invocations = []
    _.each m, (fV,fK)=>
      _.each _.filter(fV.invocations, (o)=> o.call == name), (iV,iK)=>
        @uConfig.tasks[k].invocations.push callee:fV.name, body:iV.body if iV.body.length
ezcake::getDeclarations = ->
  src = ""
  _.each @config.default.declarations, (v,k)=>
   src = "#{src}\n\n#{@template (path.join @module_path, 'templates/_declaration.template.txt'), v}"
   # console.log "src: #{src}"
  src
ezcake::getHelpers = ->
  (_.map @config.default.helpers, (v,k)=>
   @template "#{path.join @module_path, 'templates/_helper.template.txt'}", v
  ).join "\n"
ezcake::getTasks = ->
  _.each @config.default.tasks, (v,k)=>
    # console.log v
    v.args ?= ''
    v.body ?= ''
    # _.each @uConfig.commands, (v,k)=>
      # if t.invocations?
        # if (invocation = _.where t.invocations, {call:handlerName}).length
          # body += """
          # #{@strings.hash} From Command '#{v}'
            # #{'# '+t.description}
            # #{invocation[0].body}\n  
          # """
    # _.each @uConfig.modules, (v,k)=>
      # if t.invocations?
        # if (invocation = _.where t.invocations, {call:handlerName}).length
          # body += """
          # #{@strings.hash} From Module '#{v}'
            # #{'# '+t.description}
            # #{invocation[0].body}\n  
          # """
    @template "#{path.join @module_path, 'templates/_task.template.txt'}", v
  # tasks = ''
  # _.each , (t,tk)=>
    # handlerName = "on#{t.name.charAt(0).toUpperCase()}#{t.name.slice 1}"
    # body = "#{t.body || new String}"
    # _.each @uConfig.commands, (v,k)=>
      # if t.invocations?
        # if (invocation = _.where t.invocations, {call:handlerName}).length
          # body += """
          # #{@strings.hash} From Command '#{v}'
            # #{'# '+t.description}
            # #{invocation[0].body}\n  
          # """
    # _.each @uConfig.modules, (v,k)=>
      # if t.invocations?
        # if (invocation = _.where t.invocations, {call:handlerName}).length
          # body += """
          # #{@strings.hash} From Module '#{v}'
            # #{'# '+t.description}
            # #{invocation[0].body}\n  
          # """
    # tasks += """
    # #{@strings.hash} #{@strings.hash}#{@strings.hash} *#{t.name}*\n#{@strings.hash} #{t.description}\ntask '#{t.name}', '#{t.description}', (#{t.args || new String})-> #{t.name.replace /:/g, '_'} -> log ':)', green
    # #{t.name.replace /:/g, '_'} = (#{t.args || new String})->
      # #{body}
    # \n"""
  # tasks
ezcake::template = (p, params, callback)->
  fs.readFile p, {encoding:'utf-8'}, (e,data)=>
    return @error e if e?
    data = _.template data, params
    if callback and typeof callback == 'function'
      callback data
ezcake::generateConfiguration = (cB)->
  if (bundles = @uConfig.bundles)?
    _.each bundles, (v,k)=>
      if cmd[v.name]
        _.each v, (bV, bK) =>
          if bK != 'templates' 
            @uConfig[bK] = _.union( @uConfig[bK] || [], bV) if _.isObject bV 
          else
            (m = {})[v.name] = bV
            @uConfig[bK] = _.extend( @uConfig[bK] || {}, m ) if _.isObject bV
  @processTasks()
  @template "#{path.join @module_path, @config.default.cake_template}", ( 
    _.extend @uConfig, {
      reqs: (reqs = _.where @getRequires(), type:'npm')
      version: @version
      paths:@getPaths @getModCommands()
      exts: @getExts()
      callbacks: @getCallbacks()
      options: @uConfig.options || []
      templates:JSON.stringify @uConfig.templates, null, 2
    }
  ), (rendered)=>
    fs.writeFile "#{@$path}/Cakefile", rendered, null, (e)=> 
      return console.log e if e?
      cB null
  @npmPackage.addDependencies _.where (deps = @getDependencies()), {type:'npm', development:false}
  @npmPackage.addDependencies _.where(deps, {type:'npm', development:true}), true