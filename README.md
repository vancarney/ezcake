<pre>
                                  d@@@@@b
                                 @@:.@@@@@               ......
                                @@: @@@@@@@``````````````   MMM
                           ..... q@:.@@@@p               MMMMMM                           
                          (       ~_***_~             MMMMMMMMM                      
                           *                        MMMMMMMMM..                   
                           |..`*                MMMMMMMMMM.....                
                           |......`*        MMMMMMMMMM.....7MMM               
                           |..........`* MMMMMMMMMM....MMMMMMMM          
                           |.............MMMMMMM....MMMMMMMMM..                            
                           |.............MMMM...NMMMMMMMMMM...M                   
                           |.............M ...MMMMMMMMMM...MMMM     	 		   
                           |...............MMMMMMMMMM...MMMMMMM         
                           |.............MMMMMMMMM...MMMMMMMMMM       
                           |.............MMMMMM...MMMMMMMMMMM       
                           |.............MMM...MMMMMMMMMMM             
                          / ................7MMMMMMMMMMM                
                          *    ..........MMMMMMMMMMMM                  
                            `*     ......MMMMMMMMMM                      
                               `*     ...MMMMMMMM
                                  `*     MMMMM
                                      `* MMM
       ___           ___           ___           ___           ___           ___     
      /  /\         /  /\         /  /\         /  /\         /__/|         /  /\    
     /  /:/_       /  /::|       /  /:/        /  /::\       |  |:|        /  /:/_   
    /  /:/ /\     /  /:/:|      /  /:/        /  /:/\:\      |  |:|       /  /:/ /\  
   /  /:/ /:/_   /  /:/|:|__   /  /:/  ___   /  /:/~/::\   __|  |:|      /  /:/ /:/_ 
  /__/:/ /:/ /\ /__/:/ |:| /\ /__/:/  /  /\ /__/:/ /:/\:\ /__/\_|:|____ /__/:/ /:/ /\
  \  \:\/:/ /:/ \__\/  |:|/:/ \  \:\ /  /:/ \  \:\/:/__\/ \  \:\/:::::/ \  \:\/:/ /:/
   \  \::/ /:/      |  |:/:/   \  \:\  /:/   \  \::/       \  \::/~~~~   \  \::/ /:/ 
    \  \:\/:/       |  |::/     \  \:\/:/     \  \:\        \  \:\        \  \:\/:/  
     \  \::/        |  |:/       \  \::/       \  \:\        \  \:\        \  \::/   
      \__\/         |__|/         \__\/         \__\/         \__\/         \__\/    
</pre>


#### EzCake makes baking Cakefiles as easy as <i>1-2-3</i>

## Quick Start:
<p>Create a Node Module project:</p>
	$ ezcake create npm sandbox/ezcake-npm
<p>Create a Node App project:</p>
	$ ezcake create app sandbox/ezcake-app
<p>Create a Static Web App project:</p>
	$ ezcake create web sandbox/ezcake-web
<p>Create a jQuery Plugin project:</p>
	$ ezcake create plugin sandbox/ezcake-plugin

## Usage :
	$ ezcake [create (c) | init (i)] [node-app (app) | node-module (npm) | plugin | web] [name?] [options]

Options vary for each command and configuration. Additionally options can be added by ezcake configurations.
Below are the default options for the built-in configurations:

  Node-Module:

        -h, --help              output usage information
	    -V, --version           output the version number
	    -I, --ignore            ignore global config file if defined in env.EZCAKE_HOME
	    -O, --no-override       do not allow loaded configs to override each other
	    -l, --location <paths>  set path(s) of config file location(s)
	    -F, --no-config         Do not create ezcake config file
	    -0, --no-coffee         don't use coffee-script (js only)
	    -D, --no-docco          disable docco support
	    -M, --no-mocha          disable mocha support
	    -k, --markdown          enable markdown parsing (requires ruby gems, Python and PEAK)
	    -L, --no-lib            do not create 'lib' output and source directories
	    -b, --bin               create 'bin' output and source directories (useful for nodejs commandline apps)

  Node-Application:
  
	    -h, --help              output usage information
	    -V, --version           output the version number
	    -I, --ignore            ignore global config file if defined in env.EZCAKE_HOME
	    -O, --no-override       do not allow loaded configs to override each other
	    -l, --location <paths>  set path(s) of config file location(s)
	    -F, --no-config         Do not create ezcake config file
	    -0, --no-coffee         don't use coffee-script (js only)
	    -D, --no-docco          disable docco support
	    -M, --no-mocha          disable mocha support
	    -k, --markdown          enable markdown parsing (requires ruby gems, Python and PEAK)
	    -L, --no-lib            do not create 'lib' output and source directories
    
  Plugin:
  
	    -h, --help              output usage information
	    -V, --version           output the version number
	    -I, --ignore            ignore global config file if defined in env.EZCAKE_HOME
	    -O, --no-override       do not allow loaded configs to override each other
	    -l, --location <paths>  set path(s) of config file location(s)
	    -F, --no-config         Do not create ezcake config file
	    -0, --no-coffee         don't use coffee-script (js only)
	    -J, --no-jade           do not use Jade templates
	    -L, --no-less           do not use less
	    -s, --scss              use scss (sass) instead of less (requires ruby gems)
	    -c, --compass           use Compass for SCSS (requires ruby gems)
	    -D, --no-docco          disable docco support
	    -M, --no-mocha          disable mocha support
	    -U, --no-uglify         do not use uglifyjs
	    -k, --markdown          enable markdown parsing (requires ruby gems, Python and PEAK)
	    -A, --no-assets         disable static asset copying from src directory
	    -L, --no-lib            do not create 'lib' output and source directories
    

  Web:
  
	    -h, --help              output usage information
	    -V, --version           output the version number
	    -I, --ignore            ignore global config file if defined in env.EZCAKE_HOME
	    -O, --no-override       do not allow loaded configs to override each other
	    -l, --location <paths>  set path(s) of config file location(s)
	    -F, --no-config         Do not create ezcake config file
	    -0, --no-coffee         don't use coffee-script (js only)
	    -J, --no-jade           do not use Jade templates
	    -L, --no-less           do not use less
	    -s, --scss              use scss (sass) instead of less (requires ruby gems)
	    -c, --compass           use Compass for SCSS (requires ruby gems)
	    -t, --jst <engine>      use javascript template engine [dust,mustache,handlebars,hogan]
	    -D, --no-docco          disable docco support
	    -M, --no-mocha          disable mocha support
	    -U, --no-uglify         do not use uglifyjs
	    -k, --markdown          enable markdown parsing (requires ruby gems, Python and PEAK)
	    -A, --no-assets         disable static asset copying from src directory
	    -T, --no-jst            disable javascript template parsing 
    
    
## Configuring and Customizing
EzCake allows for the use of JSON files to allows the creation of custom Modules, Tasks, Headers, Helpers and Configurations.
Additionally, other config files may be referenced by passing in their locations via the `-l | -location <path>` option in the CLI.

### ezcake.conf

### Helpers

Helpers are methods that are defined to facilitate functionality that may be re-used by various tasks.

<b>usage</b>
	
		{
			"name":(String) the Helper's Name,
			"description": (String) A usefull description that will appear as a comment in the Cakefile,
			"body": (String) the Coffee-Script code to be invoked
		}

<b>example:</b>

		{
			"name":"myHelperMethod",
			"description":"This is my helper method",
			"body": "console.log 'I am very helpful'"
		}

### Tasks
Tasks are the units of work callable via Cake's CLI
Common tasks are "build", "test" and "docs". You may define any number of takss to assist you and your team amtes with your workflow.

<b>usage:</b>

		{
			"name": (String) The task's name,
			"description": (String) A usefull description that will appear as a comment in the Cakefile,
			"args" (Array) an array of arguments the task runner should accept via the commandline,
			"paths" (Array|Object) paths to be stored for use by the task runner's body code,
			"body": (String) the Coffee-Script code to be invoked
		}
	
<b>example:</b>

		{
			"name":"myTaskRunner",
			"description":"This is a task runner",
			"args" ['param1','callbackFunction']
			"paths":['src','lib']
			"body": "console.log 'The task is running...'"
		}


### Modules

Modules are typically executables that need to be installed via npm or gem and called from within tasks.
A module may be anything that gets invoked from within an exec or launch statement that takes arguments

<b>usage:</b>

		{
		      "name":(String) The task's name,
		      "description":(String) A usefull description that will appear as a comment in the Cakefile,
		      "ext": (String) the module's file extension,
		      "installer": (String) the installer program to use (npm|gem},
		      "installer_options": (String) flags to pass to the install command,
		      "paths": (Array|Object) the paths to use for the module's invocation
		      "callback": (String) the name of the callback to define,
		      "command": (Array) Commander Options for Commandline usage
		      "invocations":(Array)
		      	 {
		      	   "call":(String) callback to be invked within,
		      	   "body": (String) Coffee-Script code to be invoked when call is ran
		      	 }
		}
	
<b>example:</b>

		{
		      "name":"myModule",
		      "description":"My Module",
		      "ext": ".js",
		      "installer": "npm",
		      "installer_alias":"myModule-js"
		      "installer_options": "-g",
		      "paths": ['src','lib']
		      "callback": 'onMyModule',
		      "command": ['-m, --mymodule','include myModule support']
		      "invocations":[
		      	 {
		      	   "call":(String) callback to be invked within,
		      	   "body": (String) Coffee-Script code to be invoked when call is ran
		      	 }
		      ]
		}
	
### Configurations

<b>usage:</b>

	    {
		      "name":(String) the Configuration name,
		      "description": (String) a helpful description,
		      "alias": (String) optional name to use via command-line,
		      "commands": (Array) List of Command objects to include,
		      "modules": (Array) List of Module objects to include,
		      "tasks": (Array) List of Task objects to include,,
		      "paths": (Array|Object) List of Path confguraiotns (will override those set in other directives),
	     }
	
<b>example:</b>

	    {
		      "name":"myConfig",
		      "description": "my cusotm configuration",
		      "alias": "me",
		      "commands": ['lib','bin'],
		      "modules": ['coffee','uglifyjs'],
		      "tasks": ['build','minify'],
		      "paths": {"coffee":['src/coffee/bin','src/coffee/lib']}
	     }



### Headers
