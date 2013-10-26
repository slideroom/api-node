_ = require 'underscore'
hashes = require 'jshashes'
sha1 = new hashes.SHA1()

module.exports = (params, apiKey, accessKey) ->
  paramsCopy = _.extend {}, params
  paramsCopy['access-key'] = accessKey
  paramsArray = _.pairs paramsCopy

  paramsArray = _.sortBy paramsArray, (p) -> p[0]
  strToSign = _.map(paramsArray, (p) -> "#{p[0]}=#{p[1]}").join("\n").toLowerCase()

  params.signature = sha1.b64_hmac(apiKey, strToSign)
