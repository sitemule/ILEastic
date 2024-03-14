**FREE

///
// Hello World Example
//
// This example shows how to create a simple web service which returns a 
// a fixed string (Hello World) and some at runtime created characters (time).
//
// Start it:
// ADDLIBLE ILEASTIC
// SBMJOB CMD(CALL PGM(HELLOWORLD)) JOB(HELLOWORLD) JOBQ(QSYSNOMAX) ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://my_ibm_i:44000
// 
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///

//
// @openApi
//
// openapi: 3.0.3
// info:
//   title: Swagger Petstore - OpenAPI 3.0
//   description: |-
//     This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about
//     Swagger at [https://swagger.io](https://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!
//     You can now help us improve the API whether it's by making changes to the definition itself or to the code.
//     That way, with time, we can improve the API in general, and expose some of the new features in OAS3.
// 
//     _If you're looking for the Swagger 2.0/OAS 2.0 version of Petstore, then click [here](https://editor.swagger.io/?url=https://petstore.swagger.io/v2/swagger.yaml). Alternatively, you can load via the `Edit > Load Petstore OAS 2.0` menu option!_
//     
//     Some useful links:
//     - [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)
//     - [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)
//   termsOfService: http://swagger.io/terms/
//   contact:
//     email: apiteam@swagger.io
//   license:
//     name: Apache 2.0
//     url: http://www.apache.org/licenses/LICENSE-2.0.html
//   version: 1.0.11
// externalDocs:
//   description: Find out more about Swagger
//   url: http://swagger.io
// servers:
//   - url: https://petstore3.swagger.io/api/v3
// tags:
//   - name: pet
//     description: Everything about your Pets
//     externalDocs:
//       description: Find out more
//       url: http://swagger.io
//   - name: store
//     description: Access to Petstore orders
//     externalDocs:
//       description: Find out more about our store
//       url: http://swagger.io
//   - name: user
//     description: Operations about user
//

ctl-opt copyright('Sitemule.com  (C), 2018,2022');
ctl-opt decEdit('0,') datEdit(*YMD.) main(main);
ctl-opt debug(*yes) bndDir('ILEASTIC');
ctl-opt thread(*CONCURRENT);

/include ./headers/ileastic.rpgle

// -----------------------------------------------------------------------------
// Program Entry Points    
// -----------------------------------------------------------------------------
dcl-proc main;

    dcl-ds config likeds(il_config);
    
    config.port = 44000; 
    config.host = '*ANY';
    
    il_listen (config : %paddr(myservlet));
 
end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
//
// @openApiPath
//
//  /user/hello:
//    get:
//      tags:
//        - user
//      summary: Say hello
//      description: Returns Hello World and the current time.
//      responses:
//        '200':
//          description: successful operation
//
dcl-proc myservlet;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;


    // Write the response. The default HTTP status code is 200 - OK so we
    // don't have to set it explicitly.
    il_responseWrite(response: 'Hello world. Time is ' + %char(%timestamp));
    
end-proc;

