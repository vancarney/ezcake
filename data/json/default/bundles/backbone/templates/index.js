exports['model.coffee'] = {
name:"model.coffee",
body:"\
((global, $) ->\n\
	<% if (strict) { print('use strict'); } %>\n\
	<% if (typeof namespace !== 'undefined' && namespace !== null) { %>\n\
	<%= namespace %> = global.<%= namespace %> ?= {}\n\
	<% } else { namespace = 'global'; } %>\n\
	class <%= namespace %>.<%= name %> extends Backbone.Model\n\
		defaults:null\n\
		initialize:->\n\
			# stub for backbone.model.initialize\n\
) @, <%= DOM_LIB %>"
};

exports['model.js'] = {
name:"model.js",
body:"\
(function(global, $) {\n\
	<% if (strict) { print('use strict'); } %>\n\
	<% if (typeof namespace !== 'undefined' && namespace !== null) { %>\n\
	<%= namespace %> = global.<%= namespace %> ?= {}\n\
	<% } else { namespace = 'global'; } %>\n\
	<%= namespace %>.<%= name %> = Backbone.Model.extend({\n\
		defaults:null\n\
		initialize:function() {\n\
			\\ stub for backbone.model.initialize\n\
		}\n\
	});\n\
})(this, <%= DOM_LIB %>);"
};

exports['collection.coffee'] = {
name:"collection.coffee",
body:"\
(global, $) ->\n\
	<% if (strict) { print('use strict'); } %>\n\
	<% if (typeof(namespace) != undefined && namespace != null) { %>\n\
	<%= namespace %> = global.<%= namespace %> ?= {}\n\
	<% } else { namespace = 'global' } %>\n\
	class <%= namespace %>.<%= name %> extends Backbone.Collection\n\
) @, <%= DOM_LIB %>"
};

exports['collection.js'] = {
name:"collection.js",
body:"\
(function(global, $) {\n\
	<% if (strict) { print('use strict'); } %>\n\
	<% if (typeof namespace !== 'undefined' && namespace !== null) { %>\n\
	<%= var namespace %> = global.<%= namespace %> = if (typeof global.<%= namespace %> == undefined) ? {} : global.<%= namespace %>;\n\
	<% } else { namespace = 'global' } %>\n\
	<%= namespace %>.<%= name %> = Backbone.Collection.extend({\n\
	});\n\
})( this, <%= DOM_LIB %> );"
};