## EzCake Cake File Generator
#### (c)2012-2014 Van Carney
class ezcake
  version: '0.0.1'
  # requires [Node::FS](http://nodejs.org/api/fs.html)
  fs: require 'fs'
  # requires [async](https://npmjs.org/package/async)
  async: require 'async'
  # requires [commander](https://npmjs.org/package/commander)
  cmd: require 'commander'
  # requires [require_tree](https://npmjs.org/package/require_tree)
  require_tree: require( 'require_tree' ).require_tree
  # requires [UnderscoreJS](https://npmjs.org/package/underscore)
  _: require 'underscore'
  templates_path:'./templates'
  strings:
    hash:   '#'
    red:    '\u001b[31m'
    green:  '\u001b[32m'
    yellow: '\u001b[33m'
    reset:  '\u001b[0m'
  # Commandline Params
  ENV:undefined
  PATH:undefined
  COMMAND:undefined
  CONFIG:undefined
  NAME:undefined
  # User Selected Config
  uConfig:undefined
  #### Constructor Method
  constructor:()->  
    @config = @require_tree null
    @async.series [
      ((cb)=>
        @loadConfig @templates_path, cb
      ),
      ((cb)=>
        @createOpts cb
      ),
      ((cb)=>
        # our actual path for reference use
        @fs.realpath '.', false, (e, path)=>
          @error e if e?
          @$path = path
          cb null, "ok"
      ),
      # load the global config file if `EZCAKE_HOME` is defined and we aren't ignoring
      ((cb)=>
        if (@$home = process.env.EZCAKE_HOME) != undefined and !@cmd.ignore
          @loadConfig "#{@$home}/ezcake.json", cb
        else
          cb()
      ),
      ((cb)=>
        @preProcessArgs cb
      ),
      ((cb)=>
        # if the user has passed a location in the commandline, we will load that location now
        if @cmd.location
          @_.each @cmd.location, (l,idx)=>
            @loadConfig l, =>
              cb null, "ok" if idx == @cmd.location.length
        else
          cb null, "ok" 
      ),
      # Now that all `configs` are loaded, we can do process the complete options set
      ((cb)=>
        @processArgs cb
      ),
      ((cb)=>
        # we do this check to avoid testing conflicts
        if process.argv[1].split('/').pop() == 'ezcake'
          switch @COMMAND
            when "create", "c" then @onCreate()
            when "init", "i" then @onInit()
            else
              if typeof @COMMAND == 'undefined'
                process.argv.push '-h'
                @help()
                @cmd.usage( """
                <command> [options]
                
                  where <command> is one of:
                    create, init
                    
                  hint: 'ezcake <command> -h' will give quick help on <command>
                """).parse process.argv
                process.exit 0
              else 
                @error "Command must be either 'create' or 'init' try \'ezcake create #{@COMMAND}'"
        @cmd.usage @usage
        cb null, "ok"
      ),
      ((cb)=>
        # unset @configuration if it is help flag
        @CONFIG = null if @CONFIG == "-h"
        if @CONFIG
          @processConfiguration cb
        else
          process.argv.push '-h'
          @help()
          @cmd.parse process.argv
          process.exit 0
      ),
      ((cb)=>
        @getOpts cb
      ),
      # check for help flag
      ((cb)=>
        process.argv.push '-h' if @help()
        cb null
      ),
      ((cb)=>
        # finally parse input from arrgv
        @cmd.parse process.argv
        cb null
      ),
      ((cb)=>
        # finally parse input from arrgv
        # console.log JSON.stringify @uConfig, null, 2
        @generateConfiguration cb
      )
    ], (err,r)=>
        # If we have gotten here without error, let's write our success message
        @log "#{@strings.green}ezCake completed#{@strings.reset}\n"
        # ... and close up shop
        process.exit 0