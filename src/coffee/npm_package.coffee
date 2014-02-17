class NPMPackage
  constructor:(@path)->
    @pkgPath = "#{@path}/package.json"
  loadNPMPackage: (callback)->
    if @pkgData?
      callback null, @pkgData
      return
    fs.exists @pkgPath, (bool)=>
      if bool
        fs.readFile @pkgPath, {encoding:'utf-8'}, (e,data)=> callback?(e, if data? then @pkgData = JSON.parse data else null)
      else
        @initNPMPackage (e,data) => callback?(e, data)
  saveNPMPackage: (callback)->
    return console.error "package data must be defined" if !(@pkgData?)
    try
      fs.writeFile @pkgPath, (JSON.stringify @pkgData, null, 2), {encoding:'utf-8'}, (e,data)=> callback? e, @pkgData
    catch e
      return console.err e.message
  initNPMPackage: (callback)->
    @pkgData = 
      name: "#{@NAME}"
      author:"#{(process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE).split(path.sep).pop()}"
      version: '0.0.1'
      dependencies:{}
      devDependencies:{}
    @saveNPMPackage callback
  addDependencies: (npmItems,dev=false,callback)->
    console.log "adding deps: #{JSON.stringify npmItems, null, 2}"
    @getDependencies dev, (e,dependencies)=>
      console.log "pkgData: #{JSON.stringify @pkgData, null, 2}"
      return console.error e if e?
      _.each (if npmItems instanceof Array then npmItems else [npmItems]), (npmItem,k)=>
        return console.error  'npmItem should be an object' if !_.isObject npmItem
        itm = NPMPackage.npmItem npmItem.name, npmItem.version, npmItem.url
        if dependencies[itm.name]?
          dependencies[npmItem.name] = itm[npmItem.name]
        else
          _.extend dependencies, itm
      @saveNPMPackage callback
  removeDependencies: (npmItems,dev=false,callback)->
    return console.error 'npmItem should be an object' if !_.isObject npmItem
    @getDependencies dev, (e,dependencies)=>
      return console.error e if e?
      _.each (if npmItems instanceof Array then npmItems else [npmItems]), (npmItem,k)=>
        return console.error 'npmItem should be an object' if !_.isObject npmItem
        _.each npmItem, (v,key) => delete dependencies[k]
      @saveNPMPackage callback
  getDependencies: (dev=false,callback)->
    @loadNPMPackage (e,pkg)=>
      callback? e, if !dev then pkg.dependencies ?= {} else pkg.devDependencies ?= {}
NPMPackage.npmItem = (name,version,url)->
  return console.error 'node module name is required' if !name
  (o={})[name] = (if url? then url else version) || '*'
  o