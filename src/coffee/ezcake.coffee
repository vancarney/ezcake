## EzCake Cake File Generator
#### (c)2012-2014 Van Carney
class ezcake
  version: '0.0.1'
  module_path:process.mainModule.filename.split('/bin').shift()
  config_path:"data/json/default"
  #### Constructor Method
  constructor:()->
    @configs = new ConfigLoader
    @user_home_exists    = false
    @user_config_exists  = false
    @uPath = process.cwd()
    async.series [
      ((cb)=>
        @createOpts cb
      ),
      ((cb)=>
        # our actual path for reference use
        fs.realpath '.', false, (e, path)=>
          ezcake.error e if e?
          @$path = path
          cb null, "ok"
      ),
      ((cb)=>
        if (@home = process.env.EZCAKE_HOME) != undefined
          fs.exists "#{@home}", (bool)=>
            @user_home_exists = bool
            fs.exists "#{@home}/ezcake.json", (bool)=>
              @user_config_exists = bool
              cb null
         else
          cb null
      ),
      ((cb)=>
        @preProcessArgs cb
      ),
      ((cb)=>
        switch process.argv[2]
          when 'create','update','list','publish'
            @create_or_update cb
          else
            @processArgs cb
      ),
      ((cb)=>
        # we do this check to avoid testing conflicts
        if process.argv[1].split('/').pop() == 'ezcake'
          switch ezcake.COMMAND
            when "create" then @onCreate()
            when "update" then @onUpdate()
            when "install" then @onCreate()
            when "uninstall" then @onUninstall()
            when "list" then @onList()
            when "search" then @onSearch()
            when "publish" then @onPublish()
            when "unpublish" then @onUnpublish()
            else
              if typeof ezcake.COMMAND == 'undefined'
                cmd.usage( """
                <command> [options]
                
                  where <command> is one of:
                    create, update, install, uninstall, list, search, publish, unpublish
                    
                  hint: 'ezcake <command> -h' will give quick help on <command>
                """).parse process.argv
                process.exit 0
              else 
                ezcake.error "Command must be either 'create', 'update' or 'publish' try \'ezcake create #{ezcake.COMMAND}'"
         cmd.usage @usage
         cb null, "ok"
      ),
      ((cb)=>
        # unset ezcake.CONFIGuration if it is help flag
        ezcake.CONFIG = null if ezcake.CONFIG == "-h"
        switch ezcake.COMMAND
          when 'create', 'update', 'list' then @processConfiguration cb
          when 'publish'
            @loadConfiguration ezcake.PATH
          when 'unpublish'
            console.log "ezcake.PATH: #{ezcake.PATH}"
            @loadConfiguration ezcake.PATH
          when 'search'
            console.log 'search'
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
        switch ezcake.COMMAND
          when 'create','update'
            console.log "@create_or_update_complete"
            @create_or_update_complete cb
          # when 'list'
          # when 'publish'
          # when 'unpublish'
          else
            cb 'command was not set'
      )
    ], (err,r)=>
        # If we have gotten here without error, let's write our success message
        ezcake.log "#{ezcake.strings.green}ezCake completed#{ezcake.strings.reset}\n"
        # ... and close up shop
        process.exit 0
        
  create_or_update:(callback)->
    async.series [
      # load the global config file if `EZCAKE_HOME` is defined and we aren't ignoring
      ((cb)=>
        if @user_config_exists and cmd.ignore
          try
            process.chdir p = _.initial(@home.split path.sep).join path.sep
          catch e
            ezcake.error "Failed to change working directory to '#{p}'. #{e}"
          @configs.loadConfig _.last(@home.split path.sep), => cb()
        else
          try
            process.chdir p = _.initial("#{@module_path}/#{@config_path}".split path.sep).join path.sep
          catch e
            ezcake.error "Failed to change working directory to '#{p}'. #{e}"
          @configs.loadConfig _.last(@config_path.split path.sep), =>
            if @user_home_exists
              try
                process.chdir p = _.initial(@home.split path.sep).join path.sep
              catch e
                ezcake.error "Failed to change working directory to '#{p}'. #{e}"
              @configs.loadConfig _.last(@home.split path.sep), =>
                process.chdir @uPath
                cb()
            else
              process.chdir @uPath
              cb()
      ),
      ((cb)=>
        # if the user has passed a location in the commandline, we will load that location now
        if cmd.location
          _.each cmd.location, (location,idx)=>
            process.chdir _.initial(location.split path.sep).join path.sep
            @configs.loadConfig _.last(location.split path.sep ), =>
              process.chdir @uPath
              if idx == cmd.location.length - 1
                cb null, "ok" 
        else
          cb null, "ok" 
      ),
      ((cb)=>
        @configs.mergeConfigs()
        cb null
      ),
      # Now that all `configs` are loaded, we can do process the complete options set
      ((cb)=>
        @configs.extendConfigurations()
        @processArgs cb
      )
    ], (e) =>
      callback? e
  create_or_update_complete:(callback)->
    async.series [
      ((cb)=>
        @processor    = new Processor @configs.selectedConfig()
        @fileHelpers  = new FileHelpers @$path
        if _.keys(paths = @processor.getPaths()).length
          @fileHelpers.createPaths (_.map paths, (v,k)-> v), cb
        else
          cb()
      ),
      ((cb)=>
        if _.keys(files = @processor.getFiles()).length
          @fileHelpers.createFiles (_.map files, (v,k)-> v), cb
        else
          cb()
      ),
      ((cb)=>
        config = @processor.generateConfiguration()
        console.log JSON.stringify @processor.getDependencies(), null, 2
        @npmPackage = new NPMPackage @$path
        @npmPackage.addDependencies _.where (deps = @processor.getDependencies()), {type:'npm', development:false}
        @npmPackage.addDependencies _.where(deps, {type:'npm', development:true}), true
        # finally parse input from arrgv
        (new CakefileRenderer @$path, "#{path.join @module_path, @configs.__config.cake_template}").render config, cb
      )
    ], (e)=>
      callback? e
      
ezcake.ENV  = undefined
ezcake.PATH = undefined
ezcake.NAME = undefined
ezcake.PATH = undefined
ezcake.CONFIG  = undefined
ezcake.COMMAND = undefined