**FREE

/if defined (ILBASICAUT)
/eof
/endif

/define ILBASICAUT

///
// ILEastic : BasicAuth Plugin
//
// This module is an ILEastic plugin which retrieves the BasicAuth information
// from a HTTP request and stores the credentials in the thread local memory
// of the request.
//
// /ileastic/auth/username and /ileastic/auth/password
//
// Access to the thread local memory can be achieved through the procedure
// il_getThreadMem(request). It returns a json graph from the noxDB project.
// The single values from the graph can be retrieved with
// jx_getStr(json : '/ileastic/auth/username') to get the username f. e. .
//
// @author Mihael Schmidt
// @date   05.03.2019
// @project ILEastic
//
// @info The realm should be set with il_basicauth_setRealm().
//
// @info The plugin should be registered on the IL_PREREQUEST event.
//
// @warning The credentials need to be in UTF-8 before being Base64 encoded.
///

///
// Set realm for BasicAuth
//
// Sets the realm for BasicAuth support.
//
// @param Realm
//
// @info The realm for BasicAuth must be set prior to starting the server.
///
dcl-pr il_basicauth_setRealm extproc(*dclcase);
  realm varchar(100) const;
end-pr;
