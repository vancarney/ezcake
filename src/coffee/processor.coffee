ezcake::hasDependencies = ->
  has = @_.every @_.flatten(@_.pluck @uConfigured,  "required"), (val)=>
    (@_.find (@_.pluck @_.extend( {}, @declarations, @helpers, @uConfigured.modules), "name"), (n)=>
      n == val
    ) || false
  throw new Error "'#{val}' was required but not found" if not has
  true

ezcake::getPaths = -> 
  @uConfig.paths
ezcake::getExts = ->
  @_.compact @_.pluck @config.templates.modules, 'ext'
ezcake::getCallbacks = (list)->
  @_.compact @_.pluck list, 'callback'
ezcake::getDeclarations = ->
  # concatenate in all declarations that are defined
  @_.map(@config.templates.declarations, (v,k)=>
    return "#{@strings.hash} #{v.description || v.name + 'header'}\n#{v.body}" if v.body
  ).join '\n'
ezcake::getHelpers = ->
  helpers = ""
  # loop through any defined Helpers
  @_.each @config.templates.helpers, (v,k)=>
    helpers += """
    #{@strings.hash} #{v.description || v.name+" helper method"}
    #{v.name} = #{v.body}"""
  helpers
ezcake::getTasks = ->
  tasks = ''
  @_.each @config.templates.tasks, (t,tk)=>
    handlerName = "on#{t.name.charAt(0).toUpperCase()}#{t.name.slice 1}"
    body = "#{t.body || new String}"
    @_.each @uConfig.commands, (v,k)=>
      if t.invocations?
        if (invocation = @_.where t.invocations, {call:handlerName}).length
          body += """
          #{@strings.hash} From Command '#{v}'
            #{'# '+t.description}
            #{invocation[0].body}\n  
          """
    @_.each @uConfig.modules, (v,k)=>
      if t.invocations?
        if (invocation = @_.where t.invocations, {call:handlerName}).length
          body += """
          #{@strings.hash} From Module '#{v}'
            #{'# '+t.description}
            #{invocation[0].body}\n  
          """
    tasks += """
    #{@strings.hash} #{@strings.hash}#{@strings.hash} *#{t.name}*\n#{@strings.hash} #{t.description}\ntask '#{t.name}', '#{t.description}', (#{t.args || new String})-> #{t.name.replace /:/g, '_'} -> log ':)', green
    #{t.name.replace /:/g, '_'} = (#{t.args || new String})->
      #{body}
    \n"""
  tasks
ezcake::template = (p, params, callback)->
  @fs.readFile p, (e,data)=>
    return @error e if e?
    @_.each (data="#{data}").match( /\{([a-zA-Z0-9\.\-_]+)\}/g ), (v,k)=>
      data = data.replace v, params[v.replace(/[\{\}]/g, '')] || ""
    callback data if callback and typeof callback == 'function'
ezcake::generateConfiguration = (cB)->
  rx = new RegExp "(#{(@uConfig.modules.concat @uConfig.commands).join '|'})+"
  modcommands = @_.filter (@config.templates.modules.concat @config.templates.commands), (v) => (rx.exec v.name)?
  @template @config.templates.cake_template, (
    version:@version
    declarations: @getDeclarations()
    paths: JSON.stringify @getPaths(), null, 2
    exts: @getExts().join '|'
    callbacks: @getCallbacks modcommands
    tasks: @getTasks()
    helpers: @getHelpers()   
  ), (rendered)=>
    @fs.writeFile "#{@$path}/Cakefile", rendered, null, (e)=> 
      return console.log e if e?
      cB null