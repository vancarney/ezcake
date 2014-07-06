exports.readFile = {
"name":"readFile",
"args":["data","callback"],
"body":"fs.readFile path.normalize(@templatePath), {encoding:'utf-8'}, (e,fData)=>\n\
  ezcake.error \"Failed to fetch Cakefile Template. [#{e}]\" if e?\n\
  # parses template\n\
  try\n\
    fData = _.template fData, data\n\
  catch e\n\
    ezcake.error \"Failed to parse Cakefile Template. [#{e}]\"\n\
  # send results via callback\n\
  if callback and typeof callback == 'function'\n\
    callback fData"
};