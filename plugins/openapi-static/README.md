## OpenAPI Static

This plugins provides tools and plugins to add an OpenAPI documentation to an
ILEastic web service by adding the plugin and a generated ILE module to the ILE
program.

An OpenAPI enabled ILE program consists of the following ILE modules:
- application (main module)
- OpenAPI ILEastic plugin (optionally)
- OpenAPI document (generated)
- OpenAPI init module

The OpenAPI ILEastic plugin and OpenAPI init module are provided by the ILEastic 
project. The plugin can either by statically bound to the program as a module or
can be bound to the program as a service program.

The Open init module _must_ be bound statically to the program as does the OpenAPI
document module.


### Prerequisites

This README assumes that ILEastic and the OpenAPI static plugin has been build
successfully.


### Workflow

1. Build the application module
2. Put the OpenAPI document in the IFS
3. Generate the OpenAPI source document with the command OAPIMODGEN
4. Compile the OpenAPI source document with CRTRPGMOD with the module name OPENAPIDOC
5. Build the ILE program object including the modules of the application, 
   OPENAPIDOC, OPENAPIINI and optionally OPENAPI

Note: The OpenAPI document stream file needs to have the CCSID 1252 and the
of the stream file should also be in CCSID 1252.


### Adding OpenAPI Route

First the copy book of this plugin needs to be added.

```
/include 'ileastic/plugins/openapi-static/openapi.rpginc'
```

Then the route to the OpenAPI end point needs to be added.

```
il_addRoute(config : %paddr('ileastic_openapi_static') : IL_GET : '/openapi');
```


### Content-Type

By default the OpenAPI plugin will provide the content with the HTTP header
`Content-Type : application/openapi+yaml`.

The content type can also be configured by call `ileastic_openapi_setContentType`
if a different content type is needed.

```
ileastic_openapi_setContentType('application/yaml');
```


### Limitations

Currently this plugin only supports characters from the CCSID 1252 
(Latin 1 / ISO-8559-1) character set.
