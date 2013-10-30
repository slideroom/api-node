assert = require 'assert'

{ getClient, makeResponder } = require './server'

signer = require '../src/signer'


describe 'general responses', ->
  it 'should parse a good response', (done) ->
    options =
      body: """{ "test": "test" }"""
      code: 200

    response = makeResponder options
    getClient response, (client, cleanUp) ->
      client.get "", {}, (err, resp, body) ->
        assert.equal err, null

        expectedBody =
          test: "test"

        assert.deepEqual body, expectedBody

        cleanUp()
        done()


  testBadResponseCode = (code, done) ->
    options =
      body: """{ "message": "test" }"""
      code: code

    response = makeResponder options

    getClient response, (client, cleanUp) ->
      client.get "", {}, (err, resp, body) ->
        assert.notEqual err, null
        assert.equal resp.statusCode, code

        expectedError =
          message: "test"

        assert.deepEqual err, expectedError

        cleanUp()
        done()


  it 'should parse bad response code 400', (done) -> testBadResponseCode 400, done
  it 'should parse bad response code 403', (done) -> testBadResponseCode 403, done
  it 'should parse bad response code 404', (done) -> testBadResponseCode 404, done
  it 'should parse bad response code 410', (done) -> testBadResponseCode 410, done
  it 'should parse bad response code 500', (done) -> testBadResponseCode 500, done


  it 'should not fail json parsing in error', (done) ->
    options =
      body: """ { :dsf`"""
      code: 400

    response = makeResponder options
    getClient response, (client, cleanUp) ->
      client.get "", {}, (err, resp, body) ->
        assert.notEqual err, null
        assert.equal err, true

        cleanUp()
        done()


describe 'signatures', ->
  it 'should generate the correct signature', ->
    apiKey = "123"
    accessKey = "456"
    params1 =
      email: "test@test.com"

    params2 =
      email: "TeSt@TeSt.cOm"

    assert.equal signer(params1, apiKey, accessKey), "nDRWry9G/lr8S9UQKlC1Ih6csUs="
    assert.equal signer(params2, apiKey, accessKey), "nDRWry9G/lr8S9UQKlC1Ih6csUs="

