**FREE

ctl-opt nomain;
ctl-opt thread(*CONCURRENT);


/include 'routes.rpginc'
/include 'champions.rpginc'
/include 'ileastic/ileastic.rpgle'
/include 'llist/llist_h.rpgle'
/include 'message/message_h.rpgle'
/include 'noxdb2/noxDB2.rpgle'
/include 'psds.rpginc'
/include 'qusec_h.rpgle'


//
// @openApiPath
//
//  /champion/{id}:
//    get:
//      tags:
//        - champion
//      summary: Get champion
//      description: Returns the champion details
//      parameters:
//        - name: id
//          in: path
//          description: Id of champion to return
//          required: true
//          schema:
//            type: integer
//            format: int32
//      responses:
//        '200':
//          description: Successful operation
//        '404':
//          description: No champion with this id
//        '415':
//          description: Unsupported media type. Only JSON is supported.
//
dcl-proc champions_web_champion_get export;
  dcl-pi *n;
    request  likeds(il_request);
    response likeds(il_response);
  end-pi;
  
  dcl-s contentType varchar(100);
  dcl-ds champion likeds(champions_champion_t) inz;
  dcl-s cId varchar(10);
  dcl-s id int(10);
  dcl-s json pointer;
  
  contentType = il_getRequestHeader(request : 'Accept');
  if (contentType <> IL_MEDIA_TYPE_JSON and contentType <> IL_MEDIA_TYPE_ALL);
    response.status = IL_HTTP_UNSUPPORTED_MEDIA_TYPE;
    il_responseWrite(response : contentType + ' is not supported');
    return;
  endif;
  
  cId = il_getPathParameter(request : 'id' : '');
  monitor;
    id = %int(cId);
  on-error;
    response.status = IL_HTTP_BAD_REQUEST;
    il_responseWrite(response : 'Invalid champion id');
    return;
  endmon;
  
  champion = champions_champion_get(id);
  if (champion.id = 0);
    response.status = IL_HTTP_NOT_FOUND;
    il_responseWrite(response : 'No champion with id ' + cId);
    return;
  endif;
  
  json = championToJson(champion);
  
  response.status = IL_HTTP_OK;
  response.contentType = IL_MEDIA_TYPE_JSON;
  il_responseWrite(response : nox_AsJsonText(json));
  
  on-exit;
    nox_close(json);
end-proc;

