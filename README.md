# SlideRoom SDK for Node.js

# Example

    var SlideRoomClient = require('slideroom-sdk');

    client = new SlideRoomClient({
      apiKey: "...",
      accessKey: "...",
      email: "...",
      organizationCode: "..."
    });

    function printExport(token) {
      client.Export.download(token, function(err, resp, downloadObject) {
        if (downloadObject.pending === true) {
          // wait 10 seconds to try again
          setTimeout(function() {
            printExport(token);
          }, 10 * 1000);

          return;
        }

        console.log(downloadObject.export);
      });
    }

    client.Export.request("export name", "csv", null, function(err, resp, requestObject) {
      if (err != null) {
        return;
      }

      printExport(requestObject.token);
    });


# Install

    npm install slideroom-sdk

# Documentation


## Create new client instance

    var SlideRoomClient = require('slideroom-sdk')
    var client = new SlideRoomClient(opts);

where ```opts``` is an object

    {
      apiKey: "...",
      accessKey: "...",
      email: "...",
      organizationCode: "..."
    }

## Exports

### client.Export.request(exportName, fileFormat, savedSearchName, function(err, resp, requestObject) {})

Find or build Custom Exports in Settings->Custom Exports

```fileFormat``` can be: ```'csv'```, ```'txt'```, ```'tsv'```, ```'xlxs'```

```requestObject``` will contain

    {
      token: 123,
      submissions: 456,
      message: "..."
    }

```err``` will not be ```null``` in the event that something went wrong. ```err.message``` will contain more information.

### client.Export.download(token, function(err, resp, downloadObject) {})

After you recieve a token from a request you can check on the status and if it is ready, download the export.

```downloadObject``` will contain

    {
      pending: true|false,
      [export: "(export data)"]
    }
      
If ```pending``` is true, ```export``` will not be available.

*This may change when we implement streaming of export data.*
