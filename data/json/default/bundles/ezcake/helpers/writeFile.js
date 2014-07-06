exports.writeFile = {
"name":"writeFile",
"args":["path","data","callback"],
"dependencies":["fs","path","readFile"],
"body":"fs.writeFile path.normalize(path), data, null, (e)=>\n\
	callback? if e? then \"Failed to write File: '#{path}' [#{e}]\" else null"
};