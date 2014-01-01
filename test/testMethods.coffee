fs            = require 'fs'
_             = require 'underscore'
{execFile}    = require 'child_process'
{EzCake}      = require '../src/coffee/ezcake.coffee'
(chai         = require 'chai').should()
commands =
  basic: ['node', 'mocha-testing']
  loadedConfig: ['node', 'mocha-testing', 'create', 'loadedConfiguration', 'sandbox/loadedConfig']
  withOpts: ['node', 'mocha-testing', 'create', 'loadedConfiguration', 'sandbox/loadedConfig', '-1']
configs =
  testTask:  
    description:'a test'
    paths:['test']
    handler:'()->test'
  testCommand:
    command:['-t, --test', 'test']
    onBuild:"exec 'echo test'" 
  testModule:
    ext:"test"
    exec:"test"
    name:"test"
    paths:['test']
  replaceModule:
    ext:"replace"
    exec:"replace"
    name:"coffee"
    paths:['replace']
  testConfig:
    tasks:['testTask']
    modules:['testModule']
    commands:['testCommand']
describe 'EzCake Test Suite', ->
  process.argv = commands.basic
  it 'should instantiate', =>
    (@ezcake = new EzCake).should.be.a 'object'
  describe 'EzCake Class Properties', =>
    it 'should have @strings', =>
      @ezcake.strings.hash.should.equal '#'
      @ezcake.strings.red.should.equal '\u001b[31m'
      @ezcake.strings.green.should.equal '\u001b[32m'
      @ezcake.strings.yellow.should.equal '\u001b[33m'
      @ezcake.strings.reset.should.equal '\u001b[0m'
    it 'should have a valid version', =>
      @ezcake.version.should.match /^[0-9]+\.[0-9]{1,2}$/
    it 'should have directive objects', =>
      @ezcake.headers.should.be.a 'object'
      @ezcake.helpers.should.be.a 'object'
      @ezcake.commands.should.be.a 'object'
      @ezcake.modules.should.be.a 'object'  
      @ezcake.tasks.should.be.a 'object'
      @ezcake.configurations.should.be.a 'object'
  describe 'EzCake Class Methods', =>
    #@ezcake = new EzCake
    it 'should add a header', =>
      @ezcake.addHeader 'test', block:"test"
      ((@ezcake.headers.test.should.be.a 'object').with.property 'block').equal 'test'
    it 'should add a helper', =>
      @ezcake.addHelper 'test', method:"()->test"
      ((@ezcake.helpers.test.should.be.a 'object').with.property 'method').equal '()->test'
    it 'should add a task', =>
      @ezcake.addTask 'testTask', configs.testTask
      ((@ezcake.tasks.testTask.should.be.a 'object').with.property 'description').equal 'a test'
      ((@ezcake.tasks.testTask.should.be.a 'object').with.property 'paths').with.length 1
      ((@ezcake.tasks.testTask.should.be.a 'object').with.property 'handler').equal '()->test'
    it 'should add a command', =>
      @ezcake.addCommand 'testCommand', configs.testCommand
      ((@ezcake.commands.testCommand.should.be.a 'object').with.property 'command').with.length 2
      ((@ezcake.commands.testCommand.should.be.a 'object').with.property 'onBuild').equal "exec 'echo test'"
    it 'should add a module', =>
      @ezcake.addModule 'testModule', configs.testModule
      ((@ezcake.modules.testModule.should.be.a 'object').with.property 'ext').equal 'test'
      ((@ezcake.modules.testModule.should.be.a 'object').with.property 'exec').equal 'test'
      ((@ezcake.modules.testModule.should.be.a 'object').with.property 'paths').with.length 1
      ((@ezcake.modules.testModule.should.be.a 'object').with.property 'name').equal 'test'
    it 'should add a configuration', =>
      @ezcake.addConfiguration 'testConfig', configs.testConfig
      ((@ezcake.configurations.testConfig.should.be.a 'object').with.property 'tasks').with.length 1
      ((@ezcake.configurations.testConfig.should.be.a 'object').with.property 'modules').with.length 1
      ((@ezcake.configurations.testConfig.should.be.a 'object').with.property 'commands').with.length 1
    it 'should have mkGUID generate a GUID', =>
      @ezcake.mkGUID().should.match /^[a-z0-9]{8}\-[a-z0-9]{4}\-4[a-z0-9]{3}\-[a-z0-9]{4}\-[a-z0-9]{12}$/ 
    it 'should parse process.argv', =>
      process.argv.push '-I'
      @ezcake.preprocessArgs()
      ((@ezcake.cmd.should.be.a 'object').with.property 'ignore').to.equal true
    it 'should load a config file', =>
      @ezcake.loadConfig 'test/ezcake.json'
      @ezcake.tasks.loadedTask.should.be.a 'object'
      @ezcake.configurations.loadedConfiguration.should.be.a 'object'
    # it 'should have onCreate set the @usage and @success parameters', =>
      # @ezcake.onCreate()
      # @ezcake.usage.should.be.a 'string'
      # @ezcake.usage.should.not.equal null
      # @ezcake.usage.should.not.equal ""
      # @ezcake.success.should.be.a 'string'
      # @ezcake.success.should.not.equal null
      # @ezcake.success.should.not.equal ""
    # it 'should have onInit set the @usage and @success parameters', =>
      # @ezcake.usage = null
      # @ezcake.success = null
      # @ezcake.onInit()
      # @ezcake.usage.should.be.a 'string'
      # @ezcake.usage.should.not.equal null
      # @ezcake.usage.should.not.equal ""
      # @ezcake.success.should.be.a 'string'
      # @ezcake.success.should.not.equal null
      # @ezcake.success.should.not.equal ""
    # it 'should set properties from arguments array', =>
      # process.argv = commands.loadedConfig
      # @ezcake.processArgs()
      # @ezcake.env.should.equal 'node'
      # @ezcake.path.should.equal 'mocha-testing'
      # @ezcake.command.should.equal 'create'
      # @ezcake.configuration.should.equal 'loadedConfiguration'
    # it 'should set properties from arguments array', =>
      # @ezcake.processConfiguration()
      # @ezcake.cnf.should.be.a 'object'
    # it 'should set Commader Options with getOpts', =>
      # process.argv = commands.withOpts
      # @ezcake.getOpts()
      # @ezcake.cmd.options[@ezcake.cmd.options.length-1].short.should.equal '-1'
    # it 'should obey directives', =>
      # @ezcake.getDirectives()
      # @ezcake.callbacks.onLoadedModuleCallback.should.be.a 'string'
      # @ezcake.paths.testing[0].should.equal 'loaded'
    # it 'should have a getExts method', =>
      # (typeof @ezcake.getExts).should.equal 'function'
    # it 'should have getExts return a string', =>
      # (@exts = @ezcake.getExts()).should.be.a 'string'
    # it 'should have a getHelpers method', =>
      # (typeof @ezcake.getHelpers).should.equal 'function'
    # it 'should have getHelpers return a string', =>
      # (@helpers = @ezcake.getHelpers()).should.be.a 'string'
    # it 'helpers string should not be empty', =>
      # @helpers.length.should.not.equal 0
    # it 'should have a getCallbacks method', =>
      # (typeof @ezcake.getCallbacks).should.equal 'function'
    # it 'should have getCallbacks return a string', =>
      # (@callbacks = @ezcake.getCallbacks()).should.be.a 'string'
    # it 'callbacks string should not be empty', =>
      # @callbacks.length.should.not.equal 0
    # it 'should have a writeCakeFile method', =>
      # (typeof @ezcake.writeCakeFile).should.equal 'function'
    # it 'should replace a module', =>
      # @ezcake.addModule 'coffee', configs.replaceModule
      # ((@ezcake.modules.coffee.should.be.a 'object').with.property 'ext').equal 'replace'
      # ((@ezcake.modules.coffee.should.be.a 'object').with.property 'exec').equal 'replace'
    # it 'should have removed testModule from _defaults', =>
      # @ezcake._defaults.should.not.equal 'coffee'  