class FileHelpers
  constructor:(@basePath)->
  createPaths:(paths, callback)->
    cnt = 0
    _.each _.flatten(if (paths ?= []) instanceof Array then paths else [paths]), (v,k)=>
      fs.mkdirs path.normalize(p="#{@basePath}/#{v}"), (e)=>
        ezcake.error "Failed to create path '#{p}'. [#{e}]" if e?
        callback?() if (cnt = cnt + 1) == paths.length
  createFiles:(paths, callback)->
    cnt = 0
    _.each _.flatten(if (paths ?= []) instanceof Array then paths else [paths]), (v,k)=>
      fs.createFile path.normalize(p="#{@basePath}/#{v}"), (e)=>
        ezcake.error "Failed to create file '#{p}'. [#{e}]" if e?
        callback?() if (cnt = cnt + 1) == paths.length
  