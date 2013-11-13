_ = require 'underscore'
url = require 'url'
assert = require 'assert'

{ getClientAndServer, makeResponder } = require './server'


describe 'export requests', ->
  it 'should return a successful download request (no saved search)', (done) ->
    options =
      body: """{ "token": 123, "submissions": 456, "message": "message" }"""
      code: 202

    response = makeResponder options
    getClientAndServer response, (client, server) ->
      client.Export.request "test", "txt", null, (err, resp, body) ->
        # test the request
        req = server.lastRequest
        parsedQuery = url.parse(req.url, true).query
        assert.equal parsedQuery.export, "test"
        assert.equal parsedQuery.format, "txt"
        assert.ok not (_.has parsedQuery, "ss"), "should not contain query parameter 'ss'"

        assert.equal err, null

        expectedBody =
          token: 123
          submissions: 456
          message: "message"

        assert.deepEqual body, expectedBody

        server.cleanUp()
        done()


  it 'should return a successful download request (no saved search)', (done) ->
    options =
      body: """{ "token": 123, "submissions": 456, "message": "message" }"""
      code: 202

    response = makeResponder options
    getClientAndServer response, (client, server) ->
      client.Export.request "test", "txt", "saved search", (err, resp, body) ->
        # test the request
        req = server.lastRequest
        parsedQuery = url.parse(req.url, true).query
        assert.equal parsedQuery.export, "test"
        assert.equal parsedQuery.format, "txt"
        assert.ok _.has(parsedQuery, "ss"), "should contain query parameter 'ss'"

        assert.equal err, null

        expectedBody =
          token: 123
          submissions: 456
          message: "message"

        assert.deepEqual body, expectedBody

        server.cleanUp()
        done()


  it 'should handle an error', (done) ->
    options =
      body: """{ "message": "no go" }"""
      code: 400

    response = makeResponder options
    getClientAndServer response, (client, server) ->
      client.Export.request "test", "txt", null, (err, resp, body) ->
        assert.notEqual err, null
        assert.equal body, null

        expectedError =
          message: "no go"

        assert.deepEqual expectedError, err

        server.cleanUp()
        done()


describe 'export downloads', ->
  it 'should return a pending download request', (done) ->
    options =
      body: ""
      code: 202

    response = makeResponder options
    getClientAndServer response, (client, server) ->
      client.Export.download 123, (err, resp, body) ->
        # test the request
        req = server.lastRequest
        parsedQuery = url.parse(req.url, true).query
        assert.equal parsedQuery.token, "123"

        assert.equal err, null

        expectedBody =
          pending: true

        assert.deepEqual body, expectedBody

        server.cleanUp()
        done()


  it 'should return a report', (done) ->
    options =
      body: "this,is,a,report"
      code: 200
      type: "text/plain"

    response = makeResponder options
    getClientAndServer response, (client, server) ->
      client.Export.download 123, (err, resp, body) ->
        # test the request
        req = server.lastRequest
        parsedQuery = url.parse(req.url, true).query
        assert.equal parsedQuery.token, "123"

        assert.equal err, null

        expectedBody =
          pending: false
          export: "this,is,a,report"

        assert.deepEqual body, expectedBody

        server.cleanUp()
        done()


  it 'should handle an error', (done) ->
    options =
      body: """{ "message": "no go" }"""
      code: 400

    response = makeResponder options
    getClientAndServer response, (client, server) ->
      client.Export.download 123, (err, resp, body) ->
        assert.notEqual err, null
        assert.equal body, null

        expectedError =
          message: "no go"

        assert.deepEqual expectedError, err

        server.cleanUp()
        done()

