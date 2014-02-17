# requires [Node::FS](http://nodejs.org/api/fs.html)
fs = require 'fs'
# requires [Node::Path](http://nodejs.org/api/path.html)
path = require 'path'
# requires [async](https://npmjs.org/package/async)
async = require 'async'
# requires [commander](https://npmjs.org/package/commander)
cmd = require 'commander'
# requires [require_tree](https://npmjs.org/package/require_tree)
require_tree = require( 'require_tree' ).require_tree
# requires [UnderscoreJS](https://npmjs.org/package/underscore)
_ = require 'underscore'
#### Exports for Node and Tests
exports.EzCake = ezcake
#### Run on commandline
new ezcake if process and process.argv && process.argv[1].split('/').pop() == 'ezcake'