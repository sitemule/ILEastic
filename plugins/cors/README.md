[![Open in Visual Studio Code](https://open.vscode.dev/badges/open-in-vscode.svg)](https://open.vscode.dev/sitemule/ILEastic)
# CORS plugin
This plugin allows to set CORS response headers dynamically for selected Origins.

To enable the plugin, add this in your code before starting ILEastic server:
```
il_addPlugin(config : %Paddr('il_addCorsHeaders') : IL_PREREQUEST); 
```
If you are also using JWT plugin, make sure to register it after CORS plugin.

By default, plugin allows everything from everywhere, which is not what you really want. 
In most scenarios you will want to allow CORS from a single Origin, for example https://example.com. 
Below is an example of how to allow all methods, request and expose headers:
```
il_cors_addCorsConfiguration('^https://example\.com$' : '*' : '*' : '*');
```
The above regular expression will be matched against Origin header value sent by browser. 
If there is a match (in this example its value is http://example.com), a set of below headers 
will be added to the response:
```
Access-Control-Allow-Origin: http://example.com
Access-Control-Expose-Headers: *
Access-Control-Allow-Methods: *
Access-Control-Allow-Headers: *
```
Before sending request, browsers query this information using preflight requests, which use 
**OPTIONS** method  and **Access-Control-Request-Method** header. By default, plugin catches these requests, 
sets  above response headers and responds with **HTTP 200** code. The request is not passed further down
the plugin chain, it also does not reach any servlet. 

You can add multiple configurations for different origins, just call **il_cors_addCorsConfiguration**
multiple times. Configurations will be applied in order they were added and the first one that matches
regular expression will be used. Make sure configurations' regular expressions are mutually exclusive.

Be careful with some characters in regular expressions, like \[, \], {, }, |, ^, and $. Those are
variant characters and have different code points in different code pages. You want those to be passed
in CCSID 37. If your jobs run with CCSID 37 you should be fine with just passing string literal directly
in method's parameter. If you're using a different CCSID, you may need to pass the pattern like this:
```
dcl-s corsPattern char(1000) ccsid(37) inz('^https://example\.com$');
...
corsPattern = %trim(corsPattern) + X'00';
il_cors_addCorsConfiguration(%addr(corsPattern) : '*' : '*' : '*'); 
```
### Customizing

If you do not like the default behavior, you can register a custom handler, either for all or only 
selected origins. You register a handler by passing a pointer to a procedure which implements the 
following interface:
```
dcl-pi *n ind;
   request likeds(il_request);
   response likeds(il_response);
end-pi;
```
For example:
```
dcl-proc customHandler;
    dcl-pi *n ind;
        request likeds(il_request);
        response likeds(il_response);
    end-pi;

    // Do whatever logic you want here
    // Set some headers...
    il_addHeader(response: IL_HEADERS_CORS_EXPOSE_HEADERS: 'Content-Type');
    // Set a response status...
    response.status = IL_HTTP_OK;
    // Decide whether to pass the request further (*on) or send a response
    return *off;
end-proc;
```
and register it in the plugin:
```
il_cors_addCorsConfiguration('.*' : %paddr(customHandler));
```