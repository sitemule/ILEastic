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


## Certificate Information

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

The certificate is only available if it has been enabled by calling `il_setTlsServerCertEnabled`.

```
il_setTlsServerCertEnabled(config : IL_TRUE);
```

For more information and available keys see the GSKit API [gsk_attribute_get_cert_info](https://www.ibm.com/docs/en/i/7.4.0?topic=ssw_ibm_i_74/apis/gsk_attribute_get_cert_info.html).