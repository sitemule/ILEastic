# Integration Tests

## Basics

The program `ILBASICS` provides web service endpoints which covers the most common features of HTTP.
It supports HTTP and HTTPS. HTTPS can be activated by supplying a certificate store via environment
variables.

- ILEASTIC_ITEST_KEYFILE_PATH : IFS path to the certifcate store
- ILEASTIC_ITEST_KEYFILE_SECRET : Secret for the certificate store
- ILEASTIC_ITEST_PORT : Server socket port

```
ADDENVVAR ENVVAR(ILEASTIC_ITEST_KEYFILE_PATH) VALUE('/var/local/etc/cert/rpgnextgen/server.kdb')
ADDENVVAR ENVVAR(ILEASTIC_ITEST_KEYFILE_SECRET) VALUE('changeit')
ADDENVVAR ENVVAR(ILEASTIC_ITEST_PORT) VALUE(44001)
```

The RPGUnit test suite `ILBASICST` uses RPGunit to execute tests and executes HTTP request to 
`ILBASICS` by using the HTTP client ILEvator. It supports HTTP and HTTPS. HTTPS can be activated by
supplying a certificate store via environment variables.

- ILEASTIC_ITEST_KEYFILE_PATH : IFS path to the certifcate store
- ILEASTIC_ITEST_KEYFILE_SECRET : Secret for the certificate store
- IILEASTIC_ITEST_BASE_URL : Base URL of the web service, default: http://localhost:44000

```
ADDENVVAR ENVVAR(ILEASTIC_ITEST_KEYFILE_PATH) VALUE('/var/local/etc/cert/rpgnextgen/server.kdb')
ADDENVVAR ENVVAR(ILEASTIC_ITEST_KEYFILE_SECRET) VALUE('changeit')
ADDENVVAR ENVVAR(ILEASTIC_ITEST_BASE_URL) VALUE('https://localhost:44001')
```