## EzCake Cake File Generator
#### (c)2012-2013 Van Carney
'use strict'
version = "0.7"
# requires nodeJS FileSystem
fs = require 'fs'
# requires UnderscoreJS 
_ = require 'underscore'
# requires CoffeeScript
coffeescript = require 'coffee-script'
# requires Commander
(cmd = require 'commander').version( 'version: #{version}'
# create Commander Option 'Ignore'
).option( "-I, --ignore", "ignore global config file if defined in env.EZCAKE_HOME"
# create Commander Option 'No Override'
).option( "-O, --no-override", "do not allow loaded configs to override each other"
# create Commander Option 'Location'
).option  "-l, --location <paths>", "set path(s) of config file location(s)", (arg)->arg.split ','
# some values to use for String Output
hash    =  '#'
red     = '\u001b[31m'
green   = '\u001b[32m'
yellow  = '\u001b[33m'
reset   = '\u001b[0m'
# our actual path for reference use
$path = fs.realpathSync '.'
# function mkGuid -- creates a random enough GUID
mkGUID =->
 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c)->
    r = Math.random()*16|0 
    (if c == 'x' then r else (r&0x3|0x8)).toString 16
## log(message)
# issues log to stdout
log = (m)->
  console.log "#{m}"
## warn(message)
# issues warning to stdout
warn = (m)->
  # console.warn "#{yellow}Warning: #{m}#{reset}"
## error(message)
# issues error to stdout and terminates execution
error = (m)->
  console.error "#{red}Error: #{m}#{reset}"
  process.exit 1
## help
# adds a help flag to argv to trigger help output from Commander
help =->
  (process.argv.splice 2,idx-2) if (idx = process.argv.indexOf '-h') > -1
# initialize methods to populate our configuration deirctive objects with
_.each {"headers":{},"helpers":{},"commands":{},"modules":{},"tasks":{},"configurations":{}}, (v,k)=>
  @["#{k}"] = {}
  @["add#{k.charAt(0).toUpperCase()}#{k.substring 1, k.length-1}"] = (name,o)=>
      @["#{k}"][name] = o
## Default Headers
# <li>Define Header <b>fs</b>
@addHeader "fs", (
  require: "fs"
)
# <li>Define Header <b>util</b>
@addHeader "util", (
  block: "{print} = require 'util'"
)
# <li>Define Header <b>child_process</b>
@addHeader "child_process", (
  block: "{spawn, exec}=require 'child_process'"
)
# <li>Define Header <b>which</b>
@addHeader "which", (
  block:"""
  try
    which = require('which').sync
  catch err
    if process.platform.match(/^win/)?
      console.warn 'The which module is required for windows. try "npm install which"'
    which = null
"""
)
# Define Header <b>colors"/b>
@addHeader "colors", (
  block:"""# ANSI Terminal Colors
bold = '\x1b[0;1m'
green = '\x1b[0;32m'
reset = '\x1b[0m'
red = '\x1b[0;31m'
"""
)
## Default Tasks
# <li>Define Task <b>build</b>
@addTask "build", (
  description:"Compiles Sources"
)
# <li>Define Task <b>watch</b>
@addTask "watch", (
  description:"watch project src folders and build on change"
  handler:"""exec "supervisor -e '"+exts+"' -n exit -q -w src -x 'cake' build" """
)
# <li>Define Task <b>docs</b>
@addTask "docs", (
  description:"Generate Documentation"
  paths:["docs"]
)
# <li>Define Task <b>minify</b>
@addTask "minify", (
  description:"Minify Generated JS and HTML"
)
# <li>Define Task <b>readme</b>
@addTask "readme", (
  description:"Generate ReadMe HTML from Markdown"
)
# <li>Define Task <b>release</b>
@addTask "release", (
  description:"Copy contents of debug to release folder and minify"
  paths:["debug","www"]
  handler:"""
  exec "cp -r (paths.release[0] if paths? and paths.release) (paths.release[1] if paths? and paths.release)"
  minify()"""
)
# <li>Define Task <b>test</b>
@addTask "test", (
  description:"Runs your test suite."
  args:["options", "callback"]
  paths:["tests"]
)
# <li>Define Task <b>clean</b>
@addTask "clean", (
  description:"Cleans up generated js paths"
  handler:"""
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
)
# <li>Define Task <b>up2date</b>
@addTask "up2date", (
  description:"installs/updates referenced NPMs and Gems"
  handler:""
)
## Default Modules
# <li>Define Module <b>coffee</b>
@addModule "coffee", (
  ext:"coffee"
  exec:"npm"
  name:"coffee-script"
  options:"-g"
  paths:[".","src/coffee"]
  callback:"coffeeCallback"
  onBuild: """launch 'coffee', (['-c', '-b', '-l', '-o' ].concat paths.coffee), coffeeCallback()"""
  command:['-0, --no-coffee', 'don\'t use coffee-script (js only)']
)
# <li>Define Module <b>scss</b>
@addModule "scss", (
  ext:"scss"
  exec:"gem"
  name:"sass"
  paths:["src/scss","www/css"]
  callback:"scssCallback"
  onBuild:"""launch 'sass', paths.sass, scssCallback()"""
  command:['-s, --scss', 'use scss (sass) instead of less (requires ruby gems)']
  setFlag:"-L"
)
# <li>Define Module <b>less</b>
@addModule "less", (
  ext:"less"
  exec:"npm"
  name:"less"
  options:"-g"
  callback:"lessCallback"
  paths:["src/less","www/css"]
  onBuild:"""launch 'lessc', paths.less, lessCallback()"""
  command:['-L, --no-less', 'do not use less']
)
# <li>Define Module <b>jade</b>
@addModule "jade", (
  ext:"jade"
  exec:"npm"
  name:"jade"
  options:"-g"
  paths:["src/jade","www","src/jade/templates","src/jade/includes"]
  onBuild:"""exec 'jade paths.jade[2] -v --pretty --out paths.jade[1]'"""
  command:['-J, --no-jade', 'do not use Jade templates']
)
# <li>Define Module <b>jst</b>
@addModule "jst", (
  ext:"js"
  paths:["src/jst","www/js"]
  onBuild: """exec 'jst -t dust '+paths.jst[0]+'>'+paths.jst[1]"""
  allowed:['dust','mustache','handlebars','hogan']
  command:['-t, --jst <engine>', 'use javascript template engine [dust,mustache,handlebars,hogan]', String, 'dust']
)
# <li>Define Module <b>jquery</b>
@addModule "jquery", (
  exec:"npm"
  name:"jquery"
  options:"-g"
  command:['-q, --jquery', 'use jQuery for node']
)
# <li>Define Module <b>mocha</b>
@addModule "mocha", (
  exec:"npm"
  name:"mocha"
  options:"-g"  
  paths:['test']
  command:['-M, --no-mocha', 'disable mocha support']
  onTest:"""
      if moduleExists('mocha')
          if typeof options is 'function'
            callback = options
            options = []
          #{hash} add coffee directive
          options.push '--compilers'
          options.push 'coffee:coffee-script'
          
          launch 'mocha', options, callback
    """
)
# <li>Define Module <b>mocha</b>
@addModule "chai", (
  exec:"npm"
  name:"chai"
  options:"-g"  
  paths:['test']
  command:['-C, --no-chai', 'disable chai support']
)
# <li>Define Module <b>docco</b>
@addModule "docco", (
  exec:"npm"
  name:"docco"
  options:"-g"
  command:['-D, --no-docco', 'disable docco support']
  callback:"doccoCallback"
  onDocs:"""
  if moduleExists 'docco' && paths? && paths.coffee
      walk paths.coffee[0], (err, paths) ->
        try
          launch 'docco', paths, doccoCallback()
        catch e
          error e
  """
)
# <li>Define Module <b>markdown</b>
@addModule "markdown", (
  exec:"gem"
  name:"markdown"
  command:['-k, --markdown', 'enable markdown parsing (requires ruby gems, Python and PEAK)']
  onReadme:"""-> launch 'markdown'"""
)
# <li>Define Module <b>compass</b>
@addModule "compass", (
  ext:"scss"
  exec:"gem"
  name:"compass"
  onBuild:"""launch 'compass', ['compile', "--sass-dir="+paths.scss[1], "--css-dir="+paths.scss[0]], callback"""
  command:['-c, --compass', 'use Compass for SCSS (requires ruby gems)']
)
# <li>Define Module <b>uglify</b>
@addModule "uglify", (
  exec:"npm"
  name:"uglifyjs"
  options:"-g"
  command:["-U, --no-uglify", "do not use uglifyjs"]
  onMinify:"""
  #{hash} minify js and html paths
    if paths? and paths.uglify?
      for dir in paths.uglify[1]
        walk dir, (err, results) ->
          for file in results
            continue if file.match /\.min\.js+$/
            launch 'uglifyjs', 
            (if file.match /\.js+$/ then ['--output', dir+'/'+file.replace /\.js+$/,'.min.js', file] else ['--output', dir+'/'+file, file]
  """
)
# <li>Define Module <b>stitch</b>
@addModule "stitch", (
  exec:"npm"
  name:"stitch"
  options:"-g"
  require:true
  command:["-s, --stitch", "use Stitch JS packager"]
  paths:["www/js/lib","www/js/vendor"]
  onMinify:"""
    if paths.stitch
      try
        (stitch.createPackage
          paths:paths.stitch
        ).compile (e, src)->
          fs.writeFile 'package.js', src, (e)->
          throw e if (e) 
  """
)
## Default Commands
# <li>Define Command <b>assets</b>
@addCommand 'assets', (
  command:['-A, --no-assets', 'disable static asset copying from src directory']
  onBuild:"""exec "cp -r (paths.assets[0] if paths? and paths.assets?) (paths.assets[1] if paths? and paths.assets?)" """ 
)
# <li>Define Command <b>bin</b>
@addCommand "bin", (
  paths:["bin","src/coffee/bin"]
  command:['-b, --bin', 'create \'bin\' output and source directories (useful for nodejs commandline apps)']
  onCoffeeCallback:"""
  #{hash} try to move bin folder and cat shabang onto all files in ./bin, deleting original .js files when dones
    try
      exec "mv "+paths.coffee[0]+"/"+paths.bin[0]+"/* "+paths.bin[0] if paths.coffee?
      if (files = fs.readdirSync (paths.coffee[0]+"/"+paths.bin[0])) != null and files.length
        for file in files
          exec "echo '#{hash}!/usr/bin/env node' | cat - "+paths.bin[0]+"/"+file+" > "+((paths.bin[0]+"/"+file).split('.').shift())
          fs.unlink paths.bin[0]+"/"+file
    catch e
      error e
""" 
)
# <li>Define Command <b>lib</b>
@addCommand "lib", (
  paths:
    coffee:["lib","src/coffee"]
  command:['-L, --no-lib', 'do not create \'lib\' output and source directories']
)
# <li>Define Command <b>force</b>
@addCommand "force", (
  command:['-f, --force', 'force overwrite of default configurations']
)
# <li>Define Command <b>noJST</b>
@addCommand "noJST", (
  command:['-T, --no-jst', 'disable javascript template parsing']
)
## Default Helpers
# <li>Define Helper <b>launch</b>
@addHelper "launch", (
  method:"""
  (cmd, options=[], callback) ->
    cmd = which(cmd) if which
    app = spawn cmd, options
    app.stdout.pipe(process.stdout)
    app.stderr.pipe(process.stderr)
    app.on 'exit', (status) -> callback?() if status is 0"""
)
# <li>Define Helper <b>log</b>
@addHelper "log", (
  method:"""
  (message, color, explanation) -> 
    console.log color+message+reset+(explanation or '')"""
)
# <li>Define Helper <b>moduleExists</b>
@addHelper "moduleExists", (
  method:"""
  (name) ->
    try 
      require name 
    catch err 
      error name+ 'required: npm install '+name, red
      false"""
)
# <li>Define Helper <b>unlinkIfCoffeeFile</b>
@addHelper "unlinkIfCoffeeFile", (
  method:"""
  (file) ->
    if file.match /\.coffee$/
      fs.unlink file.replace(/\.coffee$/, '.js')
      true
    else false
"""
)
# <li>Define Helper <b>walk</b>
@addHelper "walk", (
  method:"""
  (dir, done) ->
    # Directory Traversal
    results = []
    fs.readdir dir, (err, list) ->
      return done(err, []) if err
      pending = list.length
      return done(null, results) unless pending
      for name in list
        file = dir+'/'+name
        try
          stat = fs.statSync file
        catch err
          stat = null
        if stat?.isDirectory()
          walk file, null, (err, res) ->
            results.push name for name in res
            done(null, results) unless --pending
        else
          results.push file
          done(null, results) unless --pending\n\n\n"""
)
## Default Configurations
# <li>Define Configuration <b>web</b>
@addConfiguration "web", (
  commands:['assets', 'noJST']
  modules:['coffee','jade','less','scss','compass','jst','docco','mocha','uglify','markdown']
  tasks:["build","release","watch","minify","docs","test",'up2date']
  files:"README.md"
  paths:
    release:['debug','www']
    assets:["src/assets","debug"]
    coffee:["debug/js","src/coffee"]
    uglify:['www']
    jade:["src/jade","debug", "src/jade/templates", "src/jade/include"]
    jst:["src/jst","debug/js"]
)
# <li>Define Configuration <b>plugin</b>
@addConfiguration "plugin", (
  commands:['assets','lib']
  modules:['coffee','jade','less','scss','compass','docco','mocha','uglify','markdown']
  tasks:["build","watch","minify","docs","test",'up2date']
  files:"README.md"
  paths:
    demo:["demo"]
    uglify:['lib']
    assets:["src/assets","lib"]
    coffee:["lib","src/coffee"]
    jade:["src/jade","demo", "src/jade/templates", "src/jade/include"]
)
# <li>Define Configuration <b>node-npm</b>
@addConfiguration "node-npm", (
  commands:['lib','bin']
  modules:['coffee','docco','mocha','markdown']
  tasks:["build","watch","docs","test",'up2date']
  files:"README.md"
)
# <li>Define Alias of Configuration node-npm as <b>npm</b>
@addConfiguration "npm", @configurations['node-npm']
# <li>Define Configuration <b>node-app</b>
@addConfiguration "node-app", (
  commands:['lib']
  modules:['coffee','docco','mocha','markdown']
  tasks:["build","watch","docs","test",'up2date']
  files:"README.md"
  paths:
    coffee:["src/coffee","."]
)
# <li>Define Alias of Configuration node-app as <b>app</b>
@addConfiguration "app", @configurations['node-app']
## LoadConfig(path)
# Loads Configuration at given path and processes it's Directives
loadConfig = (p)=>
  if fs.existsSync p
      try
        data = JSON.parse f if f=fs.readFileSync p
        _.each data, (v,k)=>
          if typeof @[func = "add#{k.charAt(0).toUpperCase()}#{k.substring 1, k.length-1}"] == 'function'
            _.each v, (sV,sK)=>
              if sV.inherits
                if @[k][sV.inherits] 
                  sV.options = _.extend @[k][sV.inherits], sV.options
                else 
                  error "#{k.substring 0, k.length-1} \"#{sV.inherits}\" does not exist."
              
              @[func] (sV.name || "#{k.substring 0, k.length-1}_#{mkGUID()}"), sV.options if !(cmd.override == false and @[k][v.name])
      catch e
        error e
   else
    warn "config file #{p} was not found"
# preparse args to for config file directives
args = []
_.each process.argv, (v,k)=>args.push v if (v.match /^(\-h|\-\-help)+$/) == null
cmd.parse args
loadConfig "#{$home}/conf.json" if ($home = process.env.EZCAKE_HOME) != undefined and !cmd.ignore
if cmd.location
  _.each cmd.location, (l)=>loadConfig l
if process.argv.length <3
  process.argv.push "-h"
else
  process.argv.forEach (val, index, array)=>
    return (@env = val)           if index == 0
    return (@path = val)          if index == 1
    return (@command = val)       if index == 2 && !@command && !(val.match /^\-/)
    return (@configuration = val) if index == 3 && (@command.match /create|init/) && !(val.match /^\-/)
    return (@name = val)          if index == 4 && (@command.match /create/) && !(val.match /^\-/)
$dirs = []
checkDir = (path)=>
  !fs.existsSync path
switch @command
  when "create", "c"
    usage="""create #{@configuration or '<type>'} <name> [options]
    
      Creates new #{@configuration or '<type>'} configuration as directory <name> in current path
    """
    usage += "\n  Available types: #{(_.map @configurations, (v,k,l)->k).join ', '}" if typeof @configuration == 'undefined'
    if (typeof @name != 'undefined') then $path +="/#{@name}" else process.argv.push '-h'
    success = "#{@configuration} created as #{@name}\n"
  when "init", "i"
    usage="""init #{@configuration or '<type>'} [options]
    
      Creates or Updates #{@configuration or '<type>'} Cakefile in current Project Directory
    """
    usage += "\n  Available types: #{(_.map @configurations, (v,k,l)->k).join ', '}" if typeof @configuration == 'undefined'
    success = "Cakefile updated!\n"
  else
    cmd.usage( """
    <command> [options]
    
      where <command> is one of:
        create, init
        
      ezcake <command> -h     quick help on <command>
    """)
    .parse process.argv
    process.exit
cmd.usage usage
# unset @configuration if it is help flag
@configuration = null if @configuration == "-h"
# check for help
help()
# process our configuration
if (cnf=@configurations[@configuration])?
  paths = {}
  callbacks = {}
  tasks = new String
  helpers  = new String
  exts = []
  # set up our conf object for ezcake.jason
  conf = {tasks:[],commands:[],modules:[],paths:{}}
  _.each (arr=[].concat cnf.modules, cnf.commands), (v,k)=>
    if (t = @modules[v] || @commands[v]) != undefined
      # load the command value into Commander
      cmd.option t.command[0], t.command[1]
      if (_.indexOf t.command[1]) > -1 || process.argv[process.argv.length - 1].match new RegExp "[#{t.command[0].charAt 1}]+"
        process.argv.push t.setFlag if typeof t.setFlag != 'undefined' && t.setFlag?
    else
      error "#{v} was not defined"
  # add no-config to Commander options
  cmd.option "-F, --no-config", "Do not create ezcake config file" 
  # parse input from argv
  cmd.parse process.argv
  _.each arr, (v,k)=>
    # ensure the directive is defined and not disabled
    if typeof cmd[v] != 'undefined' && cmd[v]
      # test if the directive is a module
      if typeof @modules[v] != 'undefined' && (t = @modules[v])?
        conf.modules.push v
      # test if the directive is a module
      else if typeof @commands[v] != 'undefined' && (t = @commands[v])?
        conf.commands.push v
      # did not pass either test, throw anerro and stop execution
      else
        error "#{v} was not defined"
      # test for callback and create entry if found
      callbacks["on#{t.callback.charAt(0).toUpperCase()}#{t.callback.substring(1,t.callback.length)}"] = "#{hash} Callback From '#{v}'\n#{t.callback}=()->\n" if typeof t.callback != 'undefined'
      # add any callbacks defined in our current directive
      _.each v, (cV,cK)=>
        callbacks[cK] = new String callbacks[cK]+cV if callbacks[cK]
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
          warn "paths parameter for '#{v}' must be of type Object or type Array, skipping setting for '#{v}.paths'"
      # add the current path to the aggregate paths object if defined
      paths = _.extend paths, setpath if typeof t.paths != 'undefined'
  # concatenate in all headers that are defined
  headers = _.map(@headers, (v,k)=>
    return "require '#{v.require}'" if v.require
    return "#{v.block}" if v.block
  ).join '\n'
  # add all file extensions defined in our modules to the "exts" array
  _.each cnf.modules, (v,k)=>
    (exts.push @modules[v].ext) if typeof cmd[v] != 'undefined' && cmd[v] && typeof @modules[v].ext != 'undefined' && @modules[v].ext? 
  f = ["",srcDir="src"]
  # prepare the paths object for the config
  cnf.paths = {} if typeof cnf.paths == 'undefined'
  _.each (cnf.paths = _.extend cnf.paths, paths), (v,k)->
    if typeof cmd[v] == 'undefined' || !cmd[v]
      conf.paths[k] = v
      f = f.concat _.flatten _.toArray v
  # traverse our paths array and check for path validity
  _.each f, (v,k)->
   # create path if we can
   fs.mkdirSync v if checkDir v="#{$path}/#{v}"
  # test for any defined Tasks
  if typeof cnf.tasks != 'undefined'
    # Traverse Tasks Object
    _.each cnf.tasks, (v,k,l)=>
      conf.tasks.push v
      handlerName = "on#{v.charAt(0).toUpperCase()}#{v.slice 1}"
      handlers = "#{@tasks[v].handler || new String}"
      _.each cnf.modules, (v,k)=>
        handlers += "#{hash} From Module '#{v}'\n  " if @modules[v]? and @modules[v][handlerName]
        handlers += "#{@modules[v][handlerName]}\n  " if  @modules[v]? and @modules[v][handlerName]
      tasks += """
      #{hash} #{hash}#{hash} *#{v}*\n#{hash} #{@tasks[v].description}\ntask '#{v}', '#{@tasks[v].description}', (#{@tasks[v].args || new String})-> #{v} -> log ':)', green
      #{v} = (#{@tasks[v].args || new String})->
        #{handlers}"""
  # loop through any defined Helpers
  _.each @helpers, (v,k,l)->
    helpers += """
    #{hash} #{k} helper method
    #{k} = #{v.method}"""
  try
    # write Cakefile
    fs.writeFile "#{$path}/Cakefile", """#{hash} Another Cakefile made with love by ezcake v#{version}
    #{headers}\npaths=#{JSON.stringify cnf.paths}
    exts='#{exts.join '|'}'
    #{hash}> Begin Callback Handlers
    #{_.values(callbacks).join '\n'}
    #{hash}> Begin Tasks
    #{tasks}
    #{hash}> Begin Helpers
    #{helpers}"""
    # write our config to ezcake.json unless told not to
    fs.writeFile "#{$path}/ezcake.json", "#{JSON.stringify conf, null, 2}" if cmd.config
  catch e
    error "#{e}"
  process.stdout.write "success\n"
  process.exit 0, "success"
else
  # if we got here we need help
  process.argv.push "-h"
  help()
  cmd.parse process.argv