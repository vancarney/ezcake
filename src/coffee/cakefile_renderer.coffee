class CakefileRenderer
  constructor: (@cakefilePath, @templatePath)->
  fetchTemplate: (p, params, callback)->
    fs.readFile p, {encoding:'utf-8'}, (e,data)=>
      ezcake.error e if e?
      data = _.template data, params
      if callback and typeof callback == 'function'
        callback data
  render: (data,callback)->
    try
      @fetchTemplate @templatePath, data, (rendered)=>
          fs.writeFile "#{@cakefilePath}/Cakefile", rendered, null, (e)=> 
            ezcake.error "Failed to write Cakefile [#{e}]" if e?
            callback null
    catch e
      ezcake.error "Failed to fetch Cakefile Template. [#{e}]"