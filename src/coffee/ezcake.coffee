## EzCake Cake File Generator
#### (c)2012-2013 Van Carney
'use strict'
class ezcake
  # requires [Node.js FS](http://nodejs.org/api/fs.html)
  fs: require 'fs'
  # requires [UnderscoreJS](https://github.com/documentcloud/underscore)
  _: require 'underscore'
  async: require 'async'
  version: '0.7'
  process: process
  strings:
    hash:   '#'
    red:    '\u001b[31m'
    green:  '\u001b[32m'
    yellow: '\u001b[33m'
    reset:  '\u001b[0m'
  paths:{}
  name: ""
  callbacks:{}
  tasks: new String
  helpers: new String
  exts: []
  cnf: {}
  _defaults: []
  # set up our conf object for ezcake.jason
  uConfigured: 
    tasks:[]
    commands:[]
    modules:[]
    paths:{}
  uObjects:
    modules:{}
    commands:{}
    tasks:{}
    helpers:{}
    declarations:{} 
  #### Constructor Method
  constructor:()->
    # initialize methods to populate our configuration deirctive objects with
    @_.each {"declarations":{},"helpers":{},"commands":{},"modules":{},"tasks":{},"configurations":{}}, (v,k)=>
      @["#{k}"] = {}
      @["add#{k.charAt(0).toUpperCase()}#{k.substring 1, k.length-1}"] = (o)=>
        # remove name from _defaults list if exists (this flags the new object as Custom
        @_defaults.splice idx, 1 if (idx = @_defaults.indexOf o.name) >= 0
        # add the object to the appropriate container (command, module ... etc)
        @["#{k}"][o.name] = o 
      
    # requires [Commander.js](https://github.com/visionmedia/commander.js)
    (@cmd = require 'commander').version( 'version: #{@version}'
    # set Option 'Ignore'
    ).option( "-I, --ignore", "ignore global config file if defined in env.EZCAKE_HOME"
    # set Option 'No Override'
    ).option( "-O, --no-override", "do not allow loaded configs to override each other"
    # set Option 'Location'
    ).option  "-l, --location <paths>", "set path(s) of config file location(s)", (arg)->arg.split ','

    @async.series [
      ((cb)=>
        # our actual path for reference use
        @fs.realpath '.', false, (e, path)=>
          @error e if e?
          @$path = path
          cb null, "ok"
      ),
      # load our default defintions
      ((cb)=>
        @applyDefinitions cb
      ),
      # We preprocess our args because we need to detect things such as `config` loading preferences
      ((cb)=>
        # populate _defaults with our existing default configurations
        @_defaults = @_.keys @_.extend {}, @modules, @commands, @tasks, @helpers, @declarations
        @preprocessArgs cb
      ),
      # load the global config file if `EZCAKE_HOME` is defined and we aren't ignoring
      ((cb)=>
        @loadConfig "#{@$home}/ezcake.json" if (@$home = @process.env.EZCAKE_HOME) != undefined and !@cmd.ignore
        # if the user has passed a location in the commandline, we will load that location now
        if @cmd.location
          @_.each @cmd.location, (l)=>@loadConfig l
        cb null, "ok"
      ),
      # Now that all `configs` are loaded, we can do process the complete options set
      ((cb)=>
        @processArgs()
        cb null, "ok"
      ),
      ((cb)=>
        # we do this check to avoid testing conflicts
        if @process.argv[1].split('/').pop() == 'ezcake'
          switch @command
            when "create", "c" then @onCreate()
            when "init", "i" then @onInit()
            else
              @cmd.usage( """
              <command> [options]
              
                where <command> is one of:
                  create, init
                  
                ezcake <command> -h     quick help on <command>
              """).parse @process.argv
              @process.exit
        @cmd.usage @usage
        cb null, "ok"
      ),
      ((cb)=>
        # unset @configuration if it is help flag
        @configuration = null if @configuration == "-h"
        @processConfiguration() if @configuration
        @getOpts()
        cb null
      ),
      # check for help flag
      ((cb)=>
        @help()
        cb null
      ),
      ((cb)=>
        # finally parse input from argv
        @cmd.parse @process.argv
        cb null
      ),
      # gather the user selected elements
      ((cb)=>@getDirectives cb),
      ((cb)=>@findCustomDirectives cb),
      # create paths
      ((cb)=>@createPaths cb),
      # attempt to write the Cakefile
      ((cb)=>@writeCakeFile cb),
      # attempt to write the current config to ezcake.json unless told not to
      ((cb)=>
        if @cmd.config
          @writeConfig cb
        else
          cb null
      )], (err,r)=>
        # If we have gotten here without error, let's write our success message
        @log "#{@success}\n"
        # ... and close up shop
        @process.exit 0
        
  preprocessArgs:(callback)->
    args = []
    @_.each @process.argv, (v,k)=>args.push v if (v.match /^(\-h|\-\-help)+$/) == null
    @cmd.parse args
    callback null
  createDir:(path, callback)->
    @fs.exists "#{path}", ((x)=>
      if !x
        @fs.mkdir "#{path}", (e)=>
          callback e || null
      else
        callback null
    ) 
  #### void processArgs()
  # validate `process.argv` @commandModuleArray and set variables based on it's content
  processArgs:->
    # force help for invalid command format
    if @process.argv.length <3
      @process.argv.push "-h"
    else
      # we loop through argv and set some variables for reference
      @process.argv.forEach (val, index, @commandModuleArray)=>
        # `@env` tells us it's Node
        return (@env = val)           if index == 0
        # `@path` tells us our current working directory
        return (@path = val)          if index == 1
        # `@command` should be one of `create` or `init` or one of their aliases
        return (@command = val)       if index == 2 && (typeof @command == 'undefined') && !(val.match /^\-/)
        # `@configuration` should map to a valid `ezcake.json` configuration directive
        return (@configuration = val) if index == 3 && (@command.match /create|init/) && !(val.match /^\-/)
        # ``@name` is the directory name to be created and only applicable for `create`
        return (@name = val)          if index == 4 && (@command.match /create/) && !(val.match /^\-/)
  #### LoadConfig(path)
  # Loads Configuration at given path and processes it's Directives
  loadConfig: (p)->
    @fs.exists p, (bool)=>
      return @warn "config file #{p} was not found" if !bool
      # import data from file
      @fs.readFile p, (e,d)=>
        @error e if e?
        @processConfig JSON.parse d || {}
  processConfig: (data)->
    @_.each data, (v,k)=>
      # process valid directives
      if typeof @[func = "add#{k.charAt(0).toUpperCase()}#{k.substring 1, k.length-1}"] == 'function'
        for obj in v
          # check for inheritance
          if typeof obj['inherits'] != 'undefined'
            if (s=@[k][obj.inherits])
              # if we inheit, we `_.extend` that object
              obj = @_.extend {}, @[k][obj.inherits], obj
            else
              # we throw an error if we are told to extend something that does not exist
              @error "#{k.substring 0, k.length-1} \"#{sV.inherits}\" does not exist."
          # call the method handler for this type of directive
          @[func] obj if !((@cmd? and @cmd.override == false) and @[k][obj.name]) 
  #### onCreate
  onCreate:->
    @usage="""create #{@configuration or '<type>'} <name> [options]
    
      Creates new #{@configuration or '<type>'} configuration as directory <name> in current path
    """
    @usage += "\n  Available types: #{(@_.map @configurations, (v,k,l)->k).join ', '}" if typeof @configuration == 'undefined'
    if (typeof @name != 'undefined') then @$path +="/#{@name}" else @process.argv.push '-h'
    @fs.exists @$path, (bool)=>
      if !bool
        @fs.mkdir @$path, (e)=>
          @error e if e?
          @success = "#{@configuration} created as #{@name}\n"
  #### onInit
  onInit: ->
    @usage="""init #{@configuration or '<type>'} [options]
    
      Creates or Updates #{@configuration or '<type>'} Cakefile in current Project Directory
    """
    @usage += "\n  Available types: #{(@_.map @configurations, (v,k,l)->k).join ', '}" if typeof @configuration == 'undefined'
    @success = "Cakefile updated!\n"
  #### processConfiguration
  processConfiguration:->
    # process our configuration
    if typeof (@cnf=@configurations[@configuration]) != 'undefined'
      # add no-config to Commander options
      @cmd.option "-F, --no-config", "Do not create ezcake config file"
    else
      # if we got here we need help
      @process.argv.push "-h"
  getOpts:->
    @_.each (@commandModuleArr=[].concat @cnf.modules, @cnf.commands), (v,k)=>
      if (t = @modules[v] || @commands[v]) != undefined
        # load the command value into Commander
        @cmd.option t.command[0], t.command[1]
        if (@_.indexOf t.command[1]) > -1 || @process.argv[@process.argv.length - 1].match new RegExp "[#{t.command[0].charAt 1}]+"
          @process.argv.push t.setFlag if typeof t.setFlag != 'undefined' && t.setFlag?
      else
        @error "#{v} was not defined"
  hasRequired:()->
    has = @_.every @_.flatten(@_.pluck @uConfigured,  "required"), (val)=>
      (@_.find (@_.pluck @_.extend( {}, @declarations, @helpers, @uConfigured.modules), "name"), (n)=>
        n == val
      ) || false
    throw new Error "'#{val}' was required but not found" if not has
    true
  getDirectives:(callback)->
    @_.each @commandModuleArr, (v,k)=>
      # ensure the directive is defined and not disabled via arguments
      if typeof @cmd[v] != 'undefined' && @cmd[v]
        # test if the directive is a module
        if typeof @modules[v] != 'undefined' && (t = @modules[v])?
          @uConfigured.modules.push v
        # test if the directive is a command
        else if typeof @commands[v] != 'undefined' && (t = @commands[v])?
          @uConfigured.commands.push v
        # did not pass either test, throw an error and stop execution
        else
          callback "#{v} was not defined"
        # test for callback and create entry if found
        @callbacks["on#{t.callback.charAt(0).toUpperCase()}#{t.callback.substring 1,t.callback.length}"] = "#{@strings.hash} Callback From '#{v}'\n#{t.callback}=()->\n" if typeof t.callback != 'undefined'
        # handle any path setting defined in our current directive
        switch (Object.prototype.toString.call t.paths)
          when '[object Object]'
            setpath = t.paths
          when '[object Array]'
            setpath = JSON.parse "{\"#{v}\":#{JSON.stringify t.paths}}"
          when 'undefined'
            #-- do nothing 
          else
            setpath = undefined
            # @warn "paths parameter for '#{v}' must be of type Object or type Array, skipping setting for '#{v}.paths'"
        # add the current path to the aggregate paths object if defined
        @paths = @_.extend @paths, setpath if typeof t.paths != 'undefined'
    # set final paths object based on config overrides
    @paths = @_.extend @paths, @cnf.paths
    # filter modules
    @modules  = @_.pick  @modules, @uConfigured.modules
    # filter commands
    @commands = @_.pick @commands, @uConfigured.commands
    callback null
  findCustomDirectives:(callback)->
    for name in @_.difference (@_.extend {}, @_.keys @modules, @_.keys @commands, @_.keys @tasks, @_.keys @helpers, @_.keys @declarations), @_defaults
      for kind in ["commands","modules","tasks","helpers","declarations"]
        @uObjects[kind][name] = obj if (obj = @[kind][name])?
    callback null
  # returns an array all file extensions defined by our modules
  getExts:->
    @_.compact @_.pluck @modules, 'ext'
  getPaths:->
    f = []
    @_.each (@paths), (v,k)=>
      if typeof @cmd[v] == 'undefined' || !@cmd[v]
        @uConfigured.paths[k] = v
        f = f.concat @_.flatten @_.toArray v
    f
  # traverse configured paths and create directory hierarchy
  createPaths:(cb)->
    @async.each (["", "src"].concat @getPaths()), ((p,cb2)=>
      # reset our path to working dir
      path = "#{@$path}"
      arr = p.split '/'
      arr.splice -1,0,''
      # for each item in arr we append that to `path` and attempt to create it
      @async.each arr, ((item,cb3)=>@createDir (path="#{path.replace /\/$/, ''}/#{item}"), cb3), (e)=>cb2 null
    ), (e)=>cb null
  getDeclarations:->
    # concatenate in all declarations that are defined
    @_.map(@declarations, (v,k)=>
      return "#{@strings.hash} #{v.description || v.name + 'header'}\n#{v.body}" if v.body
    ).join '\n'
  getCallbacks:->
    @_.each @callbacks, (cb, cn)=>
      @_.each (@_.pluck (@_.extend {}, @modules, @commands), cn), (cV,cK)=>
        @callbacks[cn] = new String @callbacks[cn]+cV if typeof cV != 'undefined'
    (@_.values @callbacks).join '\n'
  getHelpers:->
    helpers = ""
    # loop through any defined Helpers
    @_.each @helpers, (v,k,l)=>
      helpers += """
      #{@strings.hash} #{v.description || k +"helper method"}
      #{k} = #{v.body}"""
    helpers
  getTasks:->
    tasks = ""
    # test for any defined Tasks
    if typeof @cnf.tasks != 'undefined'
      # Traverse Tasks Object
      @_.each @cnf.tasks, (v,k,l)=>
        if @tasks[v]?
          @uConfigured.tasks.push v
          handlerName = "on#{v.charAt(0).toUpperCase()}#{v.slice 1}"
          body = "#{@tasks[v].body || new String}"
          @_.each @uConfigured.commands, (v,k)=>
            if @commands[v].invocations?
              if (invocation = @_.where @commands[v].invocations, {call:handlerName}).length
                body += """
                #{@strings.hash} From Command '#{v}'
                  #{'# '+@commands[v].description}
                  #{invocation[0].body}\n  
                """
          @_.each @uConfigured.modules, (v,k)=>
            if @modules[v].invocations?
              if (invocation = @_.where @modules[v].invocations, {call:handlerName}).length
                body += """
                #{@strings.hash} From Module '#{v}'
                  #{'# '+@modules[v].description}
                  #{invocation[0].body}\n  
                """
          tasks += """
          #{@strings.hash} #{@strings.hash}#{@strings.hash} *#{v}*\n#{@strings.hash} #{@tasks[v].description}\ntask '#{v}', '#{@tasks[v].description}', (#{@tasks[v].args || new String})-> #{v.replace /:/g, '_'} -> log ':)', green
          #{v.replace /:/g, '_'} = (#{@tasks[v].args || new String})->
            #{body}
          \n"""
    tasks
  toJSON:->
    (
      declarations:@declarations
      helpers:@helpers
      commands:@commands
      modules:@modules
      tasks:@tasks
      configurations:@configurations
    )
  toString:->
    JSON.stringify @toJSON(), null, 2
  #### writeCakeFile
  writeCakeFile:(callback)->
    s = """#{@strings.hash} Another Cakefile made with love by ezcake v#{@version}
    #{@getDeclarations()}
    # paths object for module invocation reference
    paths=#{JSON.stringify @cnf.paths, null, 2}
    # file extensions for watching
    exts='#{@getExts().join '|'}'
    #{@strings.hash} Begin Callback Handlers
    #{@getCallbacks()}
    #{@strings.hash} Begin Tasks
    #{@getTasks()}
    #{@strings.hash} Begin Helpers
    #{@getHelpers()}"""
    @fs.writeFile "#{@$path}/Cakefile", s, null, (e)=> callback e
  #### writeCakeFile
  writeConfig:(callback)->
    @fs.writeFile "#{@$path}/ezcake.json", "#{JSON.stringify {'definitions':@uObjects,'configuration':@uConfigured}, null, 2}", null, (e)=>callback e
  #### help()
  # adds a help flag to argv to trigger help output from Commander
  help:->
    (@process.argv.splice 2,idx-2) if (idx = @process.argv.indexOf '-h') > -1
  #### mkGuid()
  # creates a random enough GUID
  mkGUID:->
   'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c)-> 
      (if (r=Math.random()*16|0)>-1 and c == 'x' then r else (r&0x3|0x8)).toString 16
  #### log(message)
  # writes message to stdout
  log: (m)->
    @process.stdout.write "#{m}\n"
  #### warn(message)
  # writes message to stdout with warning text and colors
  warn: (m)->
    @process.stdout.write "#{@strings.yellow}Warning: #{m}#{@strings.reset}\n"
  #### error(message)
  # writes error to stderr and terminates execution
  error: (m)->
    @process.stderr.write "#{@strings.red}Error: #{m}#{@strings.reset}\n"
    @process.exit 1
  applyDefinitions:(callback)->
    #### Default Declarations
    # <li>Define Header <b>fs</b>
    @addDeclaration (
      name:"fs"
      description:"require Node::FS"
      body: "fs = require 'fs'"
    )
    # <li>Define Header <b>util</b>
    @addDeclaration (
      name:"utils"
      description:"require Node::Util"
      body: "{debug, error, log, print} = require 'util'"
    )
    # <li>Define Header <b>child_process</b>
    @addDeclaration (
      name:"child_process"
      description:"import Spawn and Exec from child_process"
      body: "{spawn, exec, execFile}=require 'child_process'"
    )
    # <li>Define Header <b>which</b>
    @addDeclaration (
      name:"which"
      description:"try to import the Which module",
      body:"""
      try
        which = (require 'which').sync
      catch err
        if process.platform.match(/^win/)?
          error 'The which module is required for windows. try "npm install which"'
        which = null
    """
    )
    # Define Header <b>colors</b>
    @addDeclaration (
      name:"colors"
      description:"set Terminal Colors"
      block:"""#{@strings.hash} ANSI Terminal Colors
    bold = '\x1b[0;1m'
    green = '\x1b[0;32m'
    red = '\x1b[0;31m'
    reset = '\x1b[0m'
    """
    )
    #### Default Helpers
    # <li>Define Helper <b>launch</b>
    @addHelper
      name:"launch"
      description:""" """
      requires:{declarations:["child_process"]}
      body:"""
      (cmd, options=[], callback) ->
        cmd = which(cmd) if which
        app = spawn cmd, options
        app.stdout.pipe(process.stdout)
        app.stderr.pipe(process.stderr)
        app.on 'exit', (status) -> callback?() if status is 0"""
    # <li>Define Helper <b>log</b>
    @addHelper
      name:"log"
      requires:{declarations:["colors"]}
      description:""" """
      body:"""
      (message, color, explanation) -> 
        console.log color+message+reset+(explanation or '')"""
    # <li>Define Helper <b>moduleExists</b>
    @addHelper
      name:"moduleExists"
      description:""" """
      body:"""
      (name) ->
        try 
          require name 
        catch err 
          error name+ 'required: npm install '+name, red
          false"""
    # <li>Define Helper <b>unlinkIfCoffeeFile</b>
    @addHelper
      name:"bin"
      description:""" """
      requires:{declarations:["fs"]}
      body:"""
      (file) ->
        if file.match /\.coffee$/
          fs.unlink file.replace(/\.coffee$/, '.js')
          true
        else false
    """
    # <li>Define Helper <b>walk</b>
    @addHelper
      name:"walk"
      description:""" """
      requires:{declarations:["fs"]}
      body:"""
      (dir, done) ->
        #{@strings.hash} Directory Traversal
        results = []
        fs.readdir dir, (err, list) =>
          return done(err, []) if err
          pending = list.length
          return done(null, results) unless pending
          for name in list
            fs.stat dir+'/'+name, (e,stat)=>
              stat = null if e?
              if stat?.isDirectory()
                walk file, (err, res) =>
                  results.push name for name in res
                  done(null, results) unless --pending
              else
                results.push file
                done(null, results) unless --pending\n\n\n"""
    #### Default Tasks
    # <li>Define Task <b>build</b>
    @addTask
      name: "build"
      description:"Compiles Sources"
    # <li>Define Task <b>build:release</b>
    @addTask
      name: "build:release"
      description:"Copy contents of debug to web release folder and minify"
      paths:["debug","www"]
      body:"""
      exec "cp -r #{@strings.hash}{paths.release[0]} #{@strings.hash}{paths.release[1]}" if paths? and paths.release
        """
    # <li>Define Task <b>watch</b>
    @addTask
      name: "watch"
      description:"watch project src folders and build on change"
    # <li>Define Task <b>docs</b>
    @addTask
      name: "docs"
      description:"Generate Documentation"
      paths:["docs"]
    # <li>Define Task <b>minify</b>
    @addTask
      name: "minify"
      description:"Minify Generated JS and HTML"
    # <li>Define Task <b>readme</b>
    @addTask
      name:"readme"
      description:"Generate ReadMe HTML from Markdown"
    # <li>Define Task <b>test</b>
    @addTask
      name: "test"
      description:"Runs your test suite."
      args:["options=[]", "callback"]
      paths:["tests"]
    # <li>Define Task <b>clean</b>
    @addTask
      name: "clean"
      description:"Cleans up generated js paths"
      body:"""
        try
          for file in paths.coffee
            unless unlinkIfCoffeeFile file
              walk file, (err, results) ->
                for f in results
                  unlinkIfCoffeeFile f
      
          callback?()
        catch err
          console.error red+err
        """
    # <li>Define Task <b>up2date</b>
    @addTask
      name:"up2date"
      description:"installs/updates referenced NPMs and Gems"
      body:""
    #### Default Modules
    # <li>Define Module <b>coffee</b>
    @addModule
      name:"coffee"
      description:"Enable coffee-script compiling"
      ext:"coffee"
      installer:"npm"
      installer_alias:"coffee-script"
      installer_options:"-g"
      paths:[".","src/coffee"]
      callback:"coffeeCallback"
      command:['-0, --no-coffee', 'don\'t use coffee-script (js only)']
      invocations: [
        call:"onBuild"
        body: """launch 'coffee', (['-c', '-b', '-l', '-o' ].concat paths.coffee), coffeeCallback"""
      ]
    # <li>Define Module <b>scss</b>
    @addModule
      name:"scss"
      description:"use SCSS/SASS instead of less (requires ruby gems)"
      ext:"scss"
      installer:"gem"
      installer_alias:"sass"
      callback:"scssCallback"
      paths:["src/scss","www/css"]
      command:['-s, --scss', 'use scss (sass) instead of less (requires ruby gems)']
      setFlag:"-L"
      invocations: [
        call:"onBuild"
        body: """launch 'sass', paths.sass, scssCallback"""
      ]
    # <li>Define Module <b>less</b>
    @addModule
      name:"less"
      description:""" """
      ext:"less"
      installer:"npm"
      installer_options:"-g"
      callback:"lessCallback"
      paths:["src/less","www/css"]
      command:['-L, --no-less', 'do not use less']
      invocations: [
        call:"onBuild"
        body: """launch 'lessc', paths.less, lessCallback"""
      ]
    # <li>Define Module <b>jade</b>
    @addModule
      name:"jade"
      description:""" """
      ext:"jade"
      installer:"npm"
      installer_options:"-g"
      paths:["src/jade","www","src/jade/templates","src/jade/includes"]
      command:['-J, --no-jade', 'do not use Jade templates']
      invocations: [
        call:"onBuild"
        body: """exec "jade #{@strings.hash}{paths.jade[2]} -v --pretty --out #{@strings.hash}{paths.jade[1]}" """
      ]
    # <li>Define Module <b>jst</b>
    @addModule
      name:"jst"
      description:""" """
      ext:"js"
      installer:"npm"
      installer_alias:"universal-jst"
      installer_options:"-g"
      paths:["src/jst","www/js"]
      allowed:['dust','mustache','handlebars','hogan']
      command:['-t, --jst <engine>', 'use javascript template engine [dust,mustache,handlebars,hogan]', String, 'dust']
      invocations: [
        call:"onBuild"
        body: """exec "jst -t dust #{@strings.hash}{paths.jst[0]} > #{@strings.hash}{paths.jst[1]}" """
      ]
    # <li>Define Module <b>jquery</b>
    @addModule
      name:"jquery"
      description:""" """
      installer:"npm"
      installer_options:"-g"
      command:['-q, --jquery', 'use jQuery for node']
    # <li>Define Module <b>mocha</b>
    @addModule
      name:"mocha"
      description:""" """
      installer:"npm"
      installer_options:"-g"  
      paths:['test']
      command:['-M, --no-mocha', 'disable mocha support']
      invocations: [
        call:"onTest"
        body:"""
            if moduleExists('mocha')
                if typeof options is 'function'
                  callback = options
                  options = []
                #{@strings.hash} add coffee directive
                options.push '--compilers'
                options.push 'coffee:coffee-script'
                
                launch 'mocha', options, callback
          """
      ]
    # <li>Define Module <b>mocha</b>
    @addModule
      name:"chai"
      description:""" """
      requires:{modules:["mocha"]}
      installer:"npm"
      installer_options:"-g"  
      paths:['test']
      command:['-C, --no-chai', 'disable chai support']
    # <li>Define Module <b>mocha</b>
    @addModule
      name:"supervisor"
      description:"""Use Supervisor for file watching """
      installer:"npm"
      installer_options:"-g"
      command:['-S, --no-superpvisor', 'disable supervisor support']
      paths:['src']
      invocations:[
        call:"onWatch"
        body:"""exec "supervisor -e '#{@strings.hash}{exts}' -n exit -q -w '#{@strings.hash}{paths.supervisor[0]}' -x 'cake' build" """
      ]
    # <li>Define Module <b>docco</b>
    @addModule
      name:"docco"
      description:""" """
      installer:"npm"
      installer_options:"-g"
      requires:{declarations:["child_process"], helpers:["walk"], modules:["coffee"]}
      command:['-D, --no-docco', 'disable docco support']
      callback:"doccoCallback"
      invocations: [
        call:"onDocs"
        body:"""
        if moduleExists 'docco' && paths? && paths.coffee
            walk paths.coffee[0], (err, paths) ->
              try
                launch 'docco', paths, doccoCallback()
              catch e
                error e
        """
      ]
    # <li>Define Module <b>markdown</b>
    @addModule
      name:"markdown"
      description:""" """
      installer:"gem"
      requires:{declarations:["child_process"]}
      command:['-k, --markdown', 'enable markdown parsing (requires ruby gems, Python and PEAK)']
      invocations: [
        call:"onReadme"
        body:"""-> launch 'markdown'"""
      ]
    # <li>Define Module <b>compass</b>
    @addModule
      name:"compass"
      description:""" """
      installer:"gem"
      ext:"scss"
      requires:{declarations:["child_process"]}
      callback:"compassCallback"
      command:['-c, --compass', 'use Compass for SCSS (requires ruby gems)']
      invocations: [
        call:"onBuild"
        body:"""launch 'compass', ['compile', '--sass-dir=#{@strings.hash}{paths.scss[1]}', '--css-dir=#{@strings.hash}{paths.scss[0]}'], callback"""
      ]
    # <li>Define Module <b>uglify</b>
    @addModule
      name:"uglifyjs"
      description:""" """
      installer:"npm"
      installer_options:"-g"
      requires:{declarations:["child_process"], helpers:["walk"]}
      command:["-U, --no-uglify", "do not use uglifyjs"]
      callback:"minifyCallback"
      invocations: [
        call:"onMinify"
        body:"""
        #{@strings.hash} minify js and html paths
          if paths? and paths.uglify?
            walk "#{@strings.hash}{paths.uglify[0]}", (err, results) =>
              for file in results
                continue if file.match /\.min\.js+$/
                launch 'uglifyjs', if file.match /\.js+$/ then ['--output', "dir/#{@strings.hash}{file.replace /\.js+$/,'.min.js'}", file] else ['--output', "dir/#{@strings.hash}{file}", file]
        """
      ]
    #### Default Commands
    # <li>Define Command <b>assets</b>
    @addCommand
      name:"assets"
      description:""" Copies Assets from src directory in build directory """
      command:['-A, --no-assets', 'disable static asset copying from src directory']
      requires:{declarations:["child_process"]}
      invocations:[
        call:"onBuild"
        body:"""
          exec "cp -r #{@strings.hash}{paths.assets[0]} #{@strings.hash}{paths.assets[1]}" if paths? and paths.assets?
        """
      ]
    # <li>Define Command <b>bin</b>
    @addCommand
      name:"bin"
      description:""" """
      paths:['bin','src/coffee/bin']
      requires:{declarations:["child_process", "fs"]}
      command:['-b, --bin', 'create \'bin\' output and source directories (useful for nodejs commandline apps)']
      invocations:[
        call:"onCoffeeCallback"
        body:"""
          #{@strings.hash} try to move bin folder and cat shabang onto all files in ./bin, deleting original .js files when dones
            try
              exec "mv #{@strings.hash}{paths.coffee[0]}/#{@strings.hash}{paths.bin[0]}/* #{@strings.hash}{paths.bin[0]}" if paths.coffee?
              fs.readdir ("#{@strings.hash}{paths.coffee[0]}/#{@strings.hash}{paths.bin[0]}")), (e,files)=>
                console.error e if e?
                for file in files
                  if file.match /\.js+$/
                    out = "#{@strings.hash}{paths.bin[0]}/#{@strings.hash}{file}".split('.').shift()
                    exec "echo '#{@strings.hash}!/usr/bin/env node' | cat - #{@strings.hash}{paths.bin[0]}/#{@strings.hash}{file} > #{@strings.hash}{out}", =>
                      fs.unlink "#{@strings.hash}{paths.bin[0]}/#{@strings.hash}{file}"
        """
      ]
    # <li>Define Command <b>lib</b>
    @addCommand
      name:"lib"
      description:""" """
      paths:
        coffee:["lib","src/coffee"]
      command:['-L, --no-lib', 'do not create \'lib\' output and source directories']
    # <li>Define Command <b>force</b>
    @addCommand
      name:"force"
      description:""" """
      command:['-f, --force', 'force overwrite of default configurations']
    # <li>Define Command <b>noJST</b>
    @addCommand
      name:"noJST"
      description:""" """
      command:['-T, --no-jst', 'disable javascript template parsing']
    #### Default Configurations
    # <li>Define Configuration <b>web</b>
    @addConfiguration
      name:"web"
      description:""" """
      commands:['assets', 'noJST']
      modules:['coffee','jade','less','scss','compass','jst','docco','mocha','uglifyjs','markdown']
      tasks:["build","build:release","watch","minify","docs","test",'up2date']
      files:"README.md"
      paths:
        release:['debug','www']
        assets:["src/assets","debug"]
        coffee:["debug/js","src/coffee"]
        uglify:['www']
        less:['src/less', 'debug/css']
        jade:["src/jade","debug", "src/jade/templates", "src/jade/include"]
        jst:["src/jst","debug/js"]
      invocations:[
        call:"onBuild:release"
        body:"minify()"
      ]
    # <li>Define Configuration <b>plugin</b>
    @addConfiguration
      name:"plugin"
      description:""" """
      commands:['assets','lib']
      modules:['coffee','jade','less','scss','compass','docco','mocha','uglifyjs','markdown']
      tasks:["build","watch","minify","docs","test",'up2date']
      files:"README.md"
      paths:
        demo:["demo"]
        uglify:['lib']
        assets:["src/assets","lib"]
        coffee:["lib","src/coffee"]
        jade:["src/jade","demo", "src/jade/templates", "src/jade/include"]
    # <li>Define Configuration <b>node-npm</b>
    @addConfiguration
      name:"node-npm"
      description:""" """
      commands:['lib','bin']
      modules:['coffee','docco','mocha','markdown']
      tasks:["build","watch","docs","test",'up2date']
      files:"README.md"
      paths:
        coffee:[".","src/coffee"]
        bin:["src/coffee/newbin","newbin"]
    # <li>Define Alias of Configuration node-npm as <b>npm</b>
    @addConfiguration @_.extend {}, @configurations['node-npm'], {name:"npm"}
    # <li>Define Configuration <b>node-app</b>
    @addConfiguration
      name:"node-app"
      description:""" """
      commands:['lib']
      modules:['coffee','docco','mocha','markdown']
      tasks:["build","watch","docs","test",'up2date']
      files:"README.md"
      paths:
        coffee:["src/coffee","."]
    # <li>Define Alias of Configuration node-app as <b>app</b>
    @addConfiguration @_.extend {}, @configurations['node-app'], {name:"app"}
    callback null
#### Exports for Node and Tests
(exports ? window).EzCake = ezcake
#### Run on commandline
new ezcake if process and process.argv && process.argv[1].split('/').pop() == 'ezcake'