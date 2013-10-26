SlideRoomClient = require '../src/index'
http = require 'http'

{ EventEmitter } = require('events')

port = 10240

# try to bind to a port, will call
# onListening with the server
newServer = (onListening) ->
  server = http.createServer()

  server.on 'error', (e) ->
    if e.code == 'EADDRINUSE'
      port += 1
      server.listen port

  server.on 'listening', ->
    onListening? server, port
    port += 1

  server.listen port


class TestServer extends EventEmitter
  constructor: (responder) ->
    @server = null
    @port = null
    @listening = false

    newServer (s, port) =>
      @server = s
      @port = port
      @listening = true

      @server.on 'request', responder
      @emit 'listening'


  close: -> @server?.close()

  getUrl: ->
    return null if not @listening
    "http://localhost:#{@port}"


makeResponder = (str, code = 200, type = 'application/json') -> (req, res) ->
  res.writeHead code,
    'Content-Length': str.length
    'Content-Type': type
  res.end str


getClient = (responder, cb) ->
  server = new TestServer responder

  server.on "listening", ->
    client = new SlideRoomClient
      email: "demo@demo.com"
      apiKey: "123"
      accessKey: "456"
      organizationCode: "test"
      baseUrl: server.getUrl()

    cleanUp = -> server.close()

    cb client, cleanUp




exports[k] = v for k, v of {
  TestServer
  makeResponder
  getClient
}
