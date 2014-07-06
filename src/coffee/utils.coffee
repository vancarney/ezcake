ezcake.utils =
  replaceAll:(str,map)->
    str.replace new RegExp( "^#{_.keys(map).join('|')}$", 'i'), (matched) => map[matched.toLowerCase()]
  is_intrinsic: (itm)->
    ['assert',
    'buffer',
    'child_process',
    'cluster',
    'console',
    'crypto',
    'debugger',
    'dns',
    'domain',
    'emitter',
    'fs',
    'http',
    'https',
    'net',
    'os',
    'path',
    'process',
    'punycode',
    'querystring',
    'readline',
    'repl',
    'stream',
    'string_decoder',
    'tls',
    'dgram',
    'url',
    'util',
    'vm',
    'zlib'].lastIndexOf( itm ) > -1
  is_config_element: (itm)->
    ['bundles',
    'commands'
    'configurations',
    'helpers',
    'modules',
    'options',
    'tasks',
    'templates'].lastIndexOf( itm ) > -1