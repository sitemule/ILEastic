# TLS Support in ILEastic

ILEastic uses IBM's [GSKit](https://www.ibm.com/docs/en/i/7.5.0?topic=sockets-global-security-kit-gskit-apis)
library for TLS/SSL encryption.

Currently ILEastic only supports non-default certificate stores. Those certificate stores are stored
as stream files in the IFS.

## Self Signed Certificates

Self signed certificates can be created with the PASE tool `openssl` and the
[Digital Certificate Manager](https://www.ibm.com/docs/en/i/7.5.0?topic=security-digital-certificate-manager).

Create self signed server certificate:

```
openssl req -x509  -newkey rsa:2048  -nodes  -keyout server.key  -out server.crt  -days 365  \
    -subj "/C=DE/ST=NRW/L=Minden/O=RPGNextGen/CN=ILEastic"  \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"  \
    -addext "keyUsage=digitalSignature,keyEncipherment"  \
    -addext "extendedKeyUsage=serverAuth"
```

Check content of our certificate:

```
openssl x509 -in server.crt -text -noout
```

DCM does not seem to like x509 for importing certificates so we need another format like PKCS12. `openssl` can create a PKCS12 version of our certificate:

```
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 -name server-cert -passout pass:changeit
```

Now extracting the public portion of the certificate for usage by the client:

```
openssl x509 -in server.crt -pubkey -out server.pub
```

For GSKit we need a certificate store created by the Digital Certificate Manager. So start DCM by calling https://my_ibmi:2006/dcm .

Steps:

- create new certificate store (other)
- import the PKCS12 certificate to the new certificate store
- set new certificate as default in certificate store

The new certificate store can now be used with ILEastic:

```
il_setKeyfile(config : '/my/path/to/the/certificate/store/server.kdb' : 'changeit');
```

Test with curl:

```
curl -v --cacert server.pub --url https://localhost:35800
```


## TLS Protocol Versions and Lax Mode

By default ILEastic enables TLS 1.2 and TLS 1.3:

- TLS 1.2 is required - if GSKit cannot enable it the server does not start.
- TLS 1.3 is enabled when available. If the release or the system value `QSSLPCL`
  does not allow it, a message is written to the joblog and the server continues
  with TLS 1.2 only.

Some old clients can only talk TLS 1.0 or 1.1. For those, lax mode can be enabled:

```
il_setTlsLaxMode(config : IL_TRUE);
il_setKeyfile(config : '/my/path/to/the/certificate/store/server.kdb' : 'changeit');
il_listen(config : %paddr(myServlet));
```

Lax mode only adds TLS 1.0 and TLS 1.1 to the allowed protocols. The protocols must also be
allowed by the system value `QSSLPCL` (e.g. `*OPSYS` or an explicit list containing
`*TLSV1` / `*TLSV1.1`) - otherwise GSKit refuses them and a message is written to the joblog.

On IBM i 7.4 and later the default `*OPSYS` only allows TLS 1.3 and 1.2, so a TLS 1.0 / 1.1
client is refused with `alert protocol version` (TLS alert 70) even in lax mode, until `QSSLPCL`
is changed. Older cipher suites may also have to be added to `QSSLCSL`.

Notes:

- Lax mode is off by default. Only enable it when you have to - TLS 1.0 and 1.1 are deprecated.
- Self signed server certificates do not need lax mode.
- For mTLS with self signed client certificates use
  `il_setClientAuthMode(config : IL_CLIENT_AUTH_MODE_PASSTHRU)` instead.
- Programs compiled against an older ILEastic header are not affected - they keep TLS 1.2 and 1.3.

Test which protocols the server accepts:

```
openssl s_client -connect my_ibm_i:44000 -tls1   </dev/null   # only succeeds in lax mode
openssl s_client -connect my_ibm_i:44000 -tls1_2 </dev/null   # always succeeds
```

The key store password is optional. If it is omitted, the job must have authority to the key store:

```
il_setKeyfile(config : '/my/path/to/the/certificate/store/server.kdb');
```

## Server Certificate Information

Information about the used server certificate can be queried during runtime. The data is available
via the thread local storage which is a noxDB graph and can be queried with the noxDB API, see 
`il_getThreadMem`.

Example:

```
dcl-s tls pointer;
dcl-s value varchar(100);

tls = il_getThreadMem(request);
value = jx_getStr(tls : '/ileastic/certificate/server/common_name');
```

The server certificate information is stored at the path `/ileastic/certificate/server`. The 
certificate values can be accessed via their corresponding keys. The keys are based on the 
GSKit certificate data ids. The value for `CERT_COMMON_NAME` can be access by the key `common_name`.
All values are strings.

The certificate information is only available if it has been enabled by calling `il_setTlsServerCertEnabled`,
`Tls` in this case means thread local storage.

```
il_setTlsServerCertEnabled(config : IL_TRUE);
```

For more information and available keys see the GSKit API [gsk_attribute_get_cert_info](https://www.ibm.com/docs/en/i/7.4.0?topic=ssw_ibm_i_74/apis/gsk_attribute_get_cert_info.html).



## mTLS

ILEastic supports mutual TLS which means that not only the server certificate is checked by the 
client but the client must also send a certficiate which is validated by the server).

This can be enabled by setting the `client auth mode` to something other than NONE.

With the configuration set to IL_CLIENT_AUTH_MODE_REQUIRED the client must provide a valid client 
certificate to establish a TLS connection.

With the configuration set to IL_CLIENT_AUTH_MODE_PASSTHRU the client is asked for a client 
certficate but does not need to provide one.

A requirement for this is having TLS enabled by providing a server certificate in the
configured keystore file.

All client certificates must also be available in the same keystore file.

### Client Certificate Information

Information about the provided client certificate can be queried during runtime. The data is available
via the thread local storage which is a noxDB graph and can be queried with the noxDB API, see 
`il_getThreadMem`.

Example:

```
dcl-s tls pointer;
dcl-s value varchar(100);

tls = il_getThreadMem(request);
value = jx_getStr(tls : '/ileastic/certificate/client/common_name');
```

The client certificate information is stored at the path `/ileastic/certificate/client`. The 
certificate values can be accessed via their corresponding keys. The keys are based on the 
GSKit certificate data ids. The value for `CERT_COMMON_NAME` can be access by the key `common_name`.
All values are strings.

The certificate information is only available if it has been enabled by calling `il_setTlsClientCertEnabled`,
`Tls` in this case means thread local storage.

```
il_setTlsClientCertEnabled(config : IL_TRUE);
```

For more information and available keys see the GSKit API [gsk_attribute_get_cert_info](https://www.ibm.com/docs/en/i/7.4.0?topic=ssw_ibm_i_74/apis/gsk_attribute_get_cert_info.html).

### Client Certifcate Validation Result

The result of the validation of the client certificate can be queried via the thread local storage
at `/ileastic/certificate/client/validationcode`. The value is the returned value of the call to
`gsk_attribute_get_numeric_value` with enum id `GSK_CERTIFICATE_VALIDATION_CODE`.

TLDR: validationcode = 0 means client certificate is valid

### Plugins

Plugins can access the certificate information by querying the thread local store. This can be used
to further filter requests by custom criterias.
