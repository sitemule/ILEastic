# ILEastic API documentation

## Structs

### il_varchar

Used for varying length strings in C. Use the `il_getVarcharValue` function to get the string contents.

* `Length Int(10)`
* `String Pointer`

### il_config

Used for defining a web server.

* `host   Varchar(64)`
* `post   Int(10)`
* `filler Char(4096)` - not used.

### il_request

This data structure contains the values of the incoming HTTP request. 

The values can be retrieve by using the `il_getVarcharValue` procedure or by using one of the `il_getRequest...` procedures.

* `config         pointer`
* `method         likeds(il_varchar)`
* `url            likeds(il_varchar)`
* `resource       likeds(il_varchar)`
* `queryString    likeds(il_varchar)`
* `protocol       likeds(il_varchar)`
* `headers        likeds(il_varchar)`
* `content        likeds(il_varchar)`
* `contentType    varchar(256)`
* `completeHeader likeds(il_varchar)`

### il_response

This data structure contains the details of the HTTP response which will be sent by one of the `il_response...` procedures.

* `config      pointer`
* `status      int(5)`
* `statusText  varchar(256)`
* `contentType varchar(256)`
* `charset     varchar(32)`

## APIs

### il_getVarcharValue

```
Varchar il_getVarcharValue ( il_varchar string )
```

Returns the value of a string data structure (il_varchar).

### il_getRequestMethod

```
Varchar il_getRequestMethod ( il_request request )
```

Returns the HTTP method from the request (like GET, POST, DELETE, ...)

### il_getRequestUrl

```
Varchar il_getRequestUrl ( il_request request )
```

Returns the request URL consisting of the resource and the query string.

`http://localhost:8080/api/v1/iledocs/search?q=map&scope=full` would return `/api/v1/iledocs/search?q=map&scope=full`.

### il_getRequestResource

```
Varchar il_getRequestResource ( il_request request )
```

Return the full resources path excluding the query string and the fragment.
`http://localhost:8080/api/v1/iledocs/search?q=map&scope=full would return` would return `/api/v1/iledocs/search`.

### il_getRequestQueryString

```
Varchar il_getRequestQueryString ( il_request request )
```

Returns the request query string (without the starting ? separator). For a request like `http://localhost:8080/path?query=string` you would get `query=string` as the return value. The `?` sign as a separator of the resource path and the query string is not part of the return value. 

If the URL does not contain a query string a zero length string is returned.

### il_getRequestProtocol

```
Varchar il_getRequestProtocol ( il_request request )
```

Returns the request protocol, f. e. `HTTP/1.1`.

### il_getRequestHeaders

```
Varchar il_getRequestHeaders ( il_request request )
```

Returns the request headers as they are in the HTTP message.

### il_getRequestHeader

```
Varchar il_getRequestHeader ( il_request request : String header )
```

Returns a single request header.

### il_getContent

```
Varchar il_getContent ( il_request request )
```

Returns the body content of the HTTP message. If the content exceeds the length of the return value the subfield `content` of the request data structure can be accessed directly to process the content block by block, see `il_request.content`.

### il_getFileMimeType

```
Varchar il_getFileMimeType ( Varchar(256) fileName )
```

If the requested resource is a file then the corresponding MIME type to the file will be returned.

### il_getFileExtension

```
Varchar il_getFileExtension ( Varchar(256) fileName )
```

If the requested resource is a file then the file extension will be returned. A request for `http://localhost:8080/index.html` will return `html`.

### il_listen

```
Void il_listen ( il_config config : Pointer(*proc) servlet )
```

Starts the server with the passed configuration and for the passed servlet.

### il_responseWrite

```
Void il_responseWrite ( il_response response : String data )
```

Writes the passed buffer to the HTTP message. This procedure can be called multiple times for a single HTTP response. The buffers content will be concated to a single HTTP message body.

The response data structure must be filled with the correct values (f. e. the HTTP status code) for the response on the first call of this procedure for the HTTP response.

### il_responseWriteBin

```
Void il_responseWriteBin ( il_response response : String buffer ) 
```

The content of the message will be written as is to the HTTP message without any character conversion.

The response data structure must be filled with the correct values (f. e. the HTTP status code) for the response on the first call of this procedure for the HTTP response.

### il_serveStatic

```
Void il_serveStatic ( il_response response : Varchar(256) fileName )
```

Writes the content of the file to the response message.

### il_responseWriteStream

```
Void il_responseWriteStream ( il_response response : Pointer stream )
```

Can accept a stream pointer returned by `json_stream` from noxDB
