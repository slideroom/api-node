# SlideRoom SDK for Node.js

## Example

```
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

```


## Install

```
npm install slideroom-sdk
```

## Documentation


