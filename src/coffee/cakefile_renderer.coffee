## CakefileRenderer
# Generates Cakefile from Template 
class CakefileRenderer
  ## Constructor
  # param <b>cakefilePath</b> location to place rendered Cakefile
  # param <b>templatePath</b> location of Cakefile template
  constructor: (@cakefilePath, @templatePath)->
  ## __fetchTemplate
  # consumes and parses Cakefile template
  # param <b>data</b> data to pass to template
  # param <b>callback</b> method to call on completion
  __fetchTemplate: (data, callback)->
    # attempts to read Cakefile template
    fs.readFile path.normalize(@templatePath), {encoding:'utf-8'}, (e,fData)=>
      ezcake.error "Failed to fetch Cakefile Template. [#{e}]" if e?
      # parses template
      try
        fData = _.template fData, data
      catch e
        ezcake.error "Failed to parse Cakefile Template. [#{e}]"
      # send results via callback
      if callback and typeof callback == 'function'
        callback fData
  ## render
  # generates Cakefile from passed data
  # param <b>data</b> data to pass to template
  # param <b>callback</b> method to call on completion
  render: (data,callback)->
    # attempt to retrieve rendered Cakefile from template
    @__fetchTemplate data, (rendered)=>
      # attempts to write Cakefile to disk
      fs.writeFile path.normalize("#{@cakefilePath}/Cakefile"), rendered, null, (e)=> 
        ezcake.error "Failed to write Cakefile [#{e}]" if e?
        callback null