class Export
  constructor: (@client) ->
    @resourcePrefix = "export"
    
  # format should be: txt, csv, txt, tsv
  request: (exportName, format = 'txt', savedSearch = null, cb) ->
    params =
      export: exportName
      format: format

    if savedSearch?
      params.ss = savedSearch

    @client.get "#{@resourcePrefix}/request", params, cb


  # TODO: look at also using streams
  download: (token, cb) ->
    params =
      token: token

    @client.getRaw "#{@resourcePrefix}/download", params, (err, resp, body) ->
      if err != null
        cb? err, resp, body
        return

      # still pending...
      if resp.statusCode == 202
        cb? null, resp, { pending: true }

      # report should be here
      else
        cb? null, resp, { pending: false, export: body }



module.exports = Export
