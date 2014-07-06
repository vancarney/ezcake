class NPMPackage
  constructor:(p)->
    @pkgPath = path.normalize "#{p}/package.json"
  loadNPMPackage: (callback)->
    if @pkgData?
      callback null, @pkgData
      return
    fs.exists @pkgPath, (bool)=>
      if bool
        fs.readFile @pkgPath, {encoding:'utf-8'}, (e,data)=>
          if data?
            try
              @pkgData = JSON.parse data
            catch e
              return ezcake.error "failed to parse package.json. [#{e}]"
          callback? e, @pkgData || null
      else
        @initNPMPackage (e,data) => callback?(e, data)
  saveNPMPackage: (callback)->
    return ezcake.error "package data must be defined" if !(@pkgData?)
    try
      fs.writeFile @pkgPath, (JSON.stringify @pkgData, null, 2), {encoding:'utf-8'}, (e,data)=> callback? e, @pkgData
    catch e
      return console.err e.message
  initNPMPackage: (callback)->
    @pkgData = 
      name: "#{ezcake.NAME}"
      author:"#{(process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE).split(path.sep).pop()}"
      version: '0.0.1'
      dependencies:{}
      devDependencies:{}
    @saveNPMPackage callback
  addDependencies: (npmItems,dev=false,callback)->
    @getDependencies dev, (e,dependencies)=>
      return ezcake.error e if e?
      _.each (if npmItems instanceof Array then npmItems else [npmItems]), (npmItem,k)=>
        return ezcake.error  'npmItem must be an object' if !_.isObject npmItem
        itm = NPMPackage.npmItem npmItem.name, npmItem.version, npmItem.url
        if dependencies[itm.name]?
          dependencies[npmItem.name] = itm[npmItem.name]
        else
          _.extend dependencies, itm
      @saveNPMPackage callback
  removeDependencies: (npmItems,dev=false,callback)->
    return ezcake.error 'npmItem should be an object' if !_.isObject npmItem
    @getDependencies dev, (e,dependencies)=>
      return ezcake.error e if e?
      _.each (if npmItems instanceof Array then npmItems else [npmItems]), (npmItem,k)=>
        return ezcake.error 'npmItem must be an object' if !_.isObject npmItem
        _.each npmItem, (v,key) => delete dependencies[k]
      @saveNPMPackage callback
  getDependencies: (dev=false,callback)->
    @loadNPMPackage (e,pkg)=>
      callback? e, if !dev then pkg.dependencies ?= {} else pkg.devDependencies ?= {}
NPMPackage.npmItem = (name,version,url)->
  return ezcake.error 'node module name is required' if !name
  (o={})[name] = (if url? then url else version) || '*'
  o