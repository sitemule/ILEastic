**FREE

/if defined (ILAUTHSYS)
/eof
/endif

/define ILAUTHSYS

///
// ILEastic : System Authentification Plugin
//
// This module is an ILEastic plugin which retrieves the authentification 
// information from the thread local memory of the request
//
// /ileastic/auth/username and /ileastic/auth/password
//
// and tries to authenticate on the system.
//
// Use can use this plugin by adding the following statement:
//
//     il_addPlugin(config : %paddr('il_auth_system') : IL_PREREQUEST);
//
// @author Mihael Schmidt
// @date   05.03.2019
//
// @info The plugin should be registered on the IL_PREREQUEST event.
///
