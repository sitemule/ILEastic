[![Open in Visual Studio Code](https://open.vscode.dev/badges/open-in-vscode.svg)](https://open.vscode.dev/sitemule/ILEastic)
# ILEastic

A self-contained, blazing-fast HTTP application server for the ILE environment on IBM i. Bind it into your ILE RPG project and you have a complete web application server — no CGI, no Apache, no nginx required.

ILEastic follows the same design paradigm as Node.JS: a single `il_listen` call puts your program in an event loop, calling your servlet procedure for each incoming HTTP request.

```rpgle
**FREE
ctl-opt bndDir('ILEASTIC') thread(*CONCURRENT);
/include headers/ileastic.rpgle

dcl-proc main;
    dcl-ds config likeds(IL_CONFIG);
    config.port = 44001;
    config.host = '*ANY';
    il_listen(config : %paddr(myServlet));
end-proc;

dcl-proc myServlet;
    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;
    il_responseWrite(response : 'Hello world');
end-proc;
```

Submit it and it is live:
```
SBMJOB CMD(CALL PGM(HELLOWORLD)) ALWMLTTHD(*YES) JOB(HELLOWORLD) JOBQ(QSYSNOMAX)
```

![](image.png)

---

## Prerequisites

| Requirement | Notes |
|---|---|
| IBM i 7.2 TR9 or higher | 7.4+ recommended for full TGTCCSID support |
| ILE C compiler | |
| ILE RPG compiler | |
| `git` | `yum install git` |
| `gmake` | `yum install make-gnu` |

Ensure the open source tools are in your PATH:
```
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH
```
See [Setting PATH on IBM i](https://ibmi-oss-docs.readthedocs.io/en/latest/troubleshooting/SETTING_PATH.html).

SSH must be running: `STRTCPSVR *SSHD`

---

## Quick Start — build directly on IBM i

```bash
ssh my_ibm_i
mkdir /prj && cd /prj
git clone --recurse-submodules https://github.com/sitemule/ILEastic.git
cd ILEastic
gmake
```

This creates library **ILEASTIC** on your IBM i. To build to a different library:
```bash
gmake BIN_LIB=MY_LIB
```

Build the example programs:
```bash
cd examples
gmake
```

Build all bundled plugins (cors, authsystem, basicauth, mediatype):
```bash
gmake plugins
```

---

## Build targets

All targets accept `BIN_LIB=<library>` (default `ILEASTIC`) and `TARGET_RLS=<release>` (default `*CURRENT`).

| Target | Where to run | What it does |
|---|---|---|
| `gmake` / `gmake all` | root or `src/` | Full build: compile all modules + create ILEASTIC service program |
| `gmake compile` | root or `src/` | Compile all modules (regenerates git hash) |
| `gmake bind` | root or `src/` | (Re)create the ILEASTIC service program |
| `gmake bind-update` | root | Update existing service program with any recompiled modules (faster than full bind) |
| `gmake plugins` | root | Build cors, authsystem, basicauth and mediatype plugins |
| `gmake <plugin>` | root | Build one plugin, e.g. `gmake cors` |
| `gmake install` | root | Copy copybooks to `$(USRINCDIR)/ILEastic` (default `/usr/local/include`) |
| `gmake clean` | root | Clear the library |
| `gmake test` | root | Run unit tests (requires iRPGUnit or RPGUnit) |
| `gmake all` | `examples/` | Build all example programs |
| `gmake helloworld` | `examples/` | Build one example program |
| `gmake all` | `plugins/<name>/` | Build that plugin in isolation |

### Subdirectory builds

Every major directory has its own `makefile`. You can build from within any of them directly:

```bash
cd src && gmake              # recompile core + rebind service program
cd examples && gmake         # build all examples
cd plugins/jwt && gmake      # build the JWT plugin
cd plugins/cors && gmake     # build the CORS plugin
```

---

## VS Code development workflow

The project ships with a `.vscode/tasks.json` and a helper script `.sitemule/sync_build.sh` that rsync your local clone to IBM i and then run `gmake` over SSH — so you edit locally with full IDE support and compile on IBM i with one keystroke.

### 1. Configure your connection

Copy `.env.example` to `.env` and fill in your values:

```bash
# SSH hostname or alias of your IBM i
I_HOST=my-ibmi

# IFS path where the project lives on the IBM i
DELPOY_PATH=/prj/ILEastic

# Uncomment when the project folder is mounted directly from the IBM i
# (rsync is skipped automatically for SMB/NFS mounts, but you can force it)
# SKIP_RSYNC=true
```

Add `my-ibmi` (or whatever name you chose) to your `~/.ssh/config` or `/etc/hosts`.

### 2. Available build tasks (`Ctrl+Shift+B`)

| Task | Shortcut trigger | What it does |
|---|---|---|
| **Remote sync: Build all** | select from list | rsync → `gmake all` from project root |
| **Remote sync: Build all in current directory** | select from list | rsync → finds nearest `makefile` above the open file → `gmake all` |
| **Remote sync: Compile current file** | select from list | rsync → finds nearest `makefile` → compiles only the open file; if the file is in `src/`, also runs `bind-update` |

> **Tip:** "Build all in current directory" is the most useful day-to-day task. Open any file in `src/`, `examples/`, or a plugin folder and run it — the build system automatically finds the right `makefile`.

### 3. IFS mount workflow (no rsync)

If you open the project directly from the IBM i IFS over SMB or NFS, `sync_build.sh` detects the network mount and skips rsync automatically. You can also set `SKIP_RSYNC=true` in `.env` to force this.

---

## Project structure

```
ILEastic/
├── src/              Core ILEastic modules (C and RPG) + makefile
├── headers/          Public copybooks and binder source (ileastic.rpgle, ileastic.bnd)
├── examples/         Example programs + makefile
├── plugins/
│   ├── authsystem/   Authentication system plugin
│   ├── basicauth/    HTTP Basic Auth plugin
│   ├── cors/         CORS plugin
│   ├── jwt/          JWT plugin
│   ├── kong/         Kong API Gateway registrar
│   ├── openAPI/      OpenAPI/Swagger plugin
│   └── openapi-static/ Static OpenAPI site generator
├── noxDB/            Embedded dependency (JSON/XML)
├── ILEfastCGI/       Embedded dependency (FastCGI)
├── unittests/        Unit tests (iRPGUnit)
└── makefile          Top-level orchestrator
```

---

## TLS / HTTPS

ILEastic supports TLS via IBM's GSKit library. See [TLS.md](TLS.md) for certificate setup and the `il_setKeyfile` API.

```rpgle
il_setKeyfile(config : '/path/to/server.kdb' : 'password');
```

---

## Example programs

After building the examples (`cd examples && gmake`), run them on IBM i:

```
ADDLIBLE ILEASTIC
SBMJOB CMD(CALL PGM(HELLOWORLD))  ALWMLTTHD(*YES) JOB(HELLOWORLD)  JOBQ(QSYSNOMAX)
SBMJOB CMD(CALL PGM(STATICFILE))  ALWMLTTHD(*YES) JOB(STATICFILE)  JOBQ(QSYSNOMAX)
```

| Program | Port | Description |
|---|---|---|
| `helloworld` | 44000 | Minimal hello world |
| `staticfile` | 44012 | Serve static files from IFS |
| `jsondata` | 44002 | Return JSON from SQL |
| `datachunks` | 44003 | Chunked streaming response |
| `querystr` | 44004 | Parse query string parameters |
| `multroutes` | 44005 | Multiple routes |
| `routeid` | 44006 | Route parameters |
| `jsonp` | 44007 | JSONP response |
| `base64` | 44008 | Base64 encode/decode |
| `header` | 44009 | Custom response headers |
| `invalidreq` | 44010 | Error handling |
| `jwtsecrout` | 44011 | JWT secured route |
| `scheduler` | 44013 | Background job scheduler |

Test in a browser or with curl:
```
curl http://my_ibm_i:44000
```

---

## Plugins

Plugins extend ILEastic without modifying the core. Each lives in `plugins/<name>/` with its own `makefile`.

| Plugin | Description | Build |
|---|---|---|
| **cors** | CORS headers | `gmake cors` from root |
| **authsystem** | Role-based auth system | `gmake authsystem` from root |
| **basicauth** | HTTP Basic Authentication | `gmake basicauth` from root |
| **jwt** | JSON Web Tokens | `cd plugins/jwt && gmake` |
| **openAPI** | OpenAPI/Swagger documentation | `cd plugins/openAPI && gmake` |
| **openapi-static** | Static OpenAPI site generator | `cd plugins/openapi-static && gmake` |
| **kong** | Kong API Gateway integration | `cd plugins/kong && gmake` |

Build all root-level plugins at once:
```bash
gmake plugins
```

---

## Unit tests

The `unittests/` folder contains tests runnable with [iRPGUnit](https://irpgunit.sourceforge.io) or [RPGUnit](https://rpgunit.sourceforge.io).

```bash
gmake test
```

---

## IBM i hostname tip

Add `my_ibm_i` to your local `/etc/hosts` (or `C:\Windows\System32\drivers\etc\hosts`) pointing to your IBM i IP address. Every script, task and example in this repo uses that name by convention.

[How to edit your hosts file](https://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/)

---

Happy ILEastic coding!
