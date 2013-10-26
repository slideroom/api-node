assert = require 'assert'

{ getClient, makeResponder } = require './server'


describe 'export requests', ->
  it 'should return a successful download request', (done) ->
    goodResponse = """
    {
      "token": 123,
      "submissions": 456,
      "message": "message"
    }"""

    response = makeResponder goodResponse, 202
    getClient response, (client, cleanUp) ->
      client.Export.request "test", "txt", null, (err, resp, body) ->
        assert.equal err, null

        expectedBody =
          token: 123
          submissions: 456
          message: "message"

        assert.deepEqual body, expectedBody

        cleanUp()
        done()


  it 'should handle an error', (done) ->
    badResponse = """
    {
      "message": "no go"
    }"""

    response = makeResponder badResponse, 400
    getClient response, (client, cleanUp) ->
      client.Export.request "test", "txt", null, (err, resp, body) ->
        assert.notEqual err, null
        assert.equal body, null

        expectedError =
          message: "no go"

        assert.deepEqual expectedError, err

        cleanUp()
        done()


describe 'export downloads', ->
  it 'should return a pending download request', (done) ->
    response = makeResponder "", 202
    getClient response, (client, cleanUp) ->
      client.Export.download 123, (err, resp, body) ->
        assert.equal err, null

        expectedBody =
          pending: true

        assert.deepEqual body, expectedBody

        cleanUp()
        done()


  it 'should return a pending download request', (done) ->
    reportText = "this,is,a,report"

    response = makeResponder reportText, 200, "text/plain"
    getClient response, (client, cleanUp) ->
      client.Export.download 123, (err, resp, body) ->
        assert.equal err, null

        expectedBody =
          pending: false
          export: reportText

        assert.deepEqual body, expectedBody

        cleanUp()
        done()


  it 'should handle an error', (done) ->
    badResponse = """
    {
      "message": "no go"
    }"""

    response = makeResponder badResponse, 400
    getClient response, (client, cleanUp) ->
      client.Export.download 123, (err, resp, body) ->
        assert.notEqual err, null
        assert.equal body, null

        expectedError =
          message: "no go"

        assert.deepEqual expectedError, err

        cleanUp()
        done()

