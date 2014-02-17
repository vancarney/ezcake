## EzCake Cake File Generator
#### (c)2012-2014 Van Carney
class ezcake
  version: '0.0.1'
  module_path:process.mainModule.filename.split('/bin').shift()
  config_path:"data/json/default"
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
  uConfig:{}
  #### Constructor Method
  constructor:()->  
    @config = require_tree null
    user_home_exists    = false
    user_config_exists  = false
    uPath = process.cwd()
    async.series [
      ((cb)=>
        @createOpts cb
      ),
      ((cb)=>
        # our actual path for reference use
        fs.realpath '.', false, (e, path)=>
          @error e if e?
          @$path = path
          cb null, "ok"
      ),
      ((cb)=>
        if (@home = process.env.EZCAKE_HOME) != undefined
          fs.exists "#{@home}", (bool)=>
            user_home_exists = bool
            fs.exists "#{@home}/ezcake.json", (bool)=>
              user_config_exists = bool
              cb null
      ),
      ((cb)=>
        @preProcessArgs cb
      ),
      # load the global config file if `EZCAKE_HOME` is defined and we aren't ignoring
      ((cb)=>
        if user_config_exists and cmd.ignore
          process.chdir _.initial(@home.split path.sep).join path.sep
          @loadConfig  _.last(@home.split path.sep), =>
            # @uConfig = @config
            cb()
        else
          process.chdir _.initial("#{@module_path}/#{@config_path}".split path.sep).join path.sep
          @loadConfig _.last(@config_path.split path.sep), =>
            # @uConfig = @config
            if user_home_exists
              process.chdir _.initial(@home.split path.sep).join path.sep
              @loadConfig _.last(@home.split path.sep), =>
                process.chdir uPath
                cb()
            else
              process.chdir uPath
              cb()
      ),
      ((cb)=>
        # if the user has passed a location in the commandline, we will load that location now
        if cmd.location
          _.each cmd.location, (location,idx)=>
            process.chdir _.initial(location.split path.sep).join path.sep
            @loadConfig _.last(location.split path.sep ), =>
              process.chdir uPath
              if idx == cmd.location.length - 1
                cb null, "ok" 
        else
          cb null, "ok" 
      ),
      ((cb)=>
        @mergeConfigs()
        cb null
      ),
      # Now that all `configs` are loaded, we can do process the complete options set
      ((cb)=>
        @extendConfigurations()
        # console.log @config
        #console.log JSON.stringify @config, null, 2
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
                # process.argv.push '-h'
                # @help()
                cmd.usage( """
                <command> [options]
                
                  where <command> is one of:
                    create, init
                    
                  hint: 'ezcake <command> -h' will give quick help on <command>
                """).parse process.argv
                process.exit 0
              else 
                @error "Command must be either 'create' or 'init' try \'ezcake create #{@COMMAND}'"
        cmd.usage @usage
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
          cmd.parse process.argv
          process.exit 0
      ),
      ((cb)=>
        @getOpts cb
      ),
      # check for help flag
      ((cb)=>
        if @help()
          process.argv.push '-h'
        cb null
      ),
      ((cb)=>
        # finally parse input from arrgv
        cmd.parse process.argv
        cb null
      ),
      ((cb)=>
        @npmPackage = new NPMPackage @$path
        # finally parse input from arrgv
        @generateConfiguration cb
      )
    ], (err,r)=>
        # If we have gotten here without error, let's write our success message
        @log "#{@strings.green}ezCake completed#{@strings.reset}\n"
        # ... and close up shop
        process.exit 0