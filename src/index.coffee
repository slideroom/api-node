_ = require 'underscore'
request = require 'request'
url = require 'url'

signer = require './signer'

resources =
  Export: require './export'

class SlideRoomClient

  # options = {
  #   apiKey: '...'
  #   accessKey: '...'
  #   email: '...'
  #   organizationCode: '...'
  #
  #   requestTimeSpan: 123 // defaults to 1 minute
  #   baseUrl: '...' // defaults to https://api.slideroom.com
  # }
  constructor: (options) ->
    @options =
      apiKey: 'AABBCCDDEE'
      accessKey: 'abcdefg'
      email: ''
      organizationCode: ''
      requestTimeSpan: 1 * 60 * 1000
      baseUrl: 'https://api.slideroom.com'

    _.extend @options, options

    @setupResources()


  setupResources: =>
    for resourceName, resourceClass of resources
      this[resourceName] = new resourceClass(this)


  signParams: (params) => signer params, @options.apiKey, @options.accessKey


  buildUrl: (path, params) =>
    parsedURL = url.parse @options.baseUrl
    parsedURL.pathname = "#{@options.organizationCode}/#{path}"
    parsedURL.query =
      email: @options.email
      expires: Math.floor((new Date().getTime() + @options.requestTimeSpan) / 1000)

    _.extend parsedURL.query, params
    @signParams parsedURL.query

    returnUrl = url.format parsedURL
    #console.log returnUrl
    returnUrl


  handleError: (body, resp, cb) =>
    errorObject = null
    try
      errorObject = JSON.parse body
    catch e
      # could not decode the json...  just use a generic error
      cb? true, resp, null
      return

    cb? errorObject, resp, null


  getRaw: (path, params = {}, cb) =>
    requestOptions =
      url: @buildUrl(path, params)
      headers:
        "User-Agent": "SlideRoom Node.js client (0.0.1)"

    request requestOptions, (err, resp, body) =>
      if err != null
        cb? err, null, null
        return

      if resp.statusCode in [ 500, 410, 404, 403, 400 ]
        @handleError body, resp, cb
        return

      cb? err, resp, body


  get: (path, params = {}, cb) =>
    @getRaw path, params, (err, resp, body) =>
      if err != null
        cb? err, resp, body
        return

      parsedJSON = null
      try
        parsedJSON = JSON.parse body
      catch e
        cb? true, resp, body
        return

      cb? null, resp, parsedJSON



module.exports = SlideRoomClient

