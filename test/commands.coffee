fs            = require 'fs'
_             = require 'underscore'
{execFile}    = require 'child_process'
{ezcake}      = require '../src/coffee/ezcake.coffee'
commands      = require '../src/coffee/commands'
(chai         = require 'chai').should()

describe 'EzCake::Commands Test Suite', ->
  it 'should have onCreate set the @usage and @success parameters', =>
    ezcake.onCreate()
    ezcake.usage.should.be.a 'string'
    ezcake.usage.should.not.equal null
    ezcake.usage.should.not.equal ""
    ezcake.success.should.be.a 'string'
    ezcake.success.should.not.equal null
    ezcake.success.should.not.equal ""
  it 'should have onInit set the @usage and @success parameters', =>
    ezcake.usage = null
    ezcake.success = null
    ezcake.onInit()
    ezcake.usage.should.be.a 'string'
    ezcake.usage.should.not.equal null
    ezcake.usage.should.not.equal ""
    ezcake.success.should.be.a 'string'
    ezcake.success.should.not.equal null
    ezcake.success.should.not.equal ""
  it 'should set properties from arguments array', =>
    process.argv = commands.loadedConfig
    ezcake.processArgs()
    ezcake.env.should.equal 'node'
    ezcake.path.should.equal 'mocha-testing'
    ezcake.command.should.equal 'create'
    ezcake.configuration.should.equal 'loadedConfiguration'
  it 'should set properties from arguments array', =>
    ezcake.processConfiguration()
    ezcake.cnf.should.be.a 'object'