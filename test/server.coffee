_ = require 'underscore'
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
    @lastRequest = null

    newServer (s, port) =>
      @server = s
      @port = port
      @listening = true

      @server.on 'request', (req, res) =>
        responder req, res
        @lastRequest = req

      @emit 'listening'


  close: -> @server?.close()

  cleanUp: -> @close()

  getUrl: ->
    return null if not @listening
    "http://localhost:#{@port}"


# options = {
#   body: ""
#   code: 200 // status code
#   type: "..." // defaults to application/json
# }
makeResponder = (options) -> (req, res) ->
  _.defaults options, { type: "application/json" }
  res.writeHead options.code,
    'Content-Length': options.body.length
    'Content-Type': options.type
  res.end options.body


getClientAndServer = (responder, cb) ->
  server = new TestServer responder

  server.on "listening", ->
    client = new SlideRoomClient
      email: "demo@demo.com"
      apiKey: "123"
      accessKey: "456"
      organizationCode: "test"
      baseUrl: server.getUrl()

    cleanUp = -> server.close()

    cb client, server




exports[k] = v for k, v of {
  TestServer
  makeResponder
  getClientAndServer
}
