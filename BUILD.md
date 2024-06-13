## ILEastic

### Folder Structure
* headers - contains the copybooks which are used in this project including the ones 
            exported to the user of these service programs
* src - contains any source of this project (code, internal copybooks, binder 
        source)
* plugins - ILEastic plugins , each plugin has its own subfolder
* unittests - unit tests usable with iRPGUnit
* noxDB - embedded dependency
* ILEfastCGI - embedded dependency


### Prerequisites
This project needs the noxDB and ILEfastCGI projects to build. Those projects can
be fetched by adding the parameter `--recurse-submodules` to the `git clone` command.

For the binding process the location of the service programs NOXDB, ILEFASTCGI
defaults to `*LIBL`. If the service programs are not in the library list the 
corresponding library can be specified with the parameter `BIND_LIB` which is 
passed to the `make` command.


### Build
The project gets build with the tool `gmake`. All necessary objects will be
created with it. `gmake` is installable via `yum`.

The target library can be passed to the make command as a parameter, _BIN\_LIB_.

    gmake BIN_LIB=MY_LIB

It defaults to the libray `ILEASTIC`. 

The target OS version can be passed with the parameter `TARGET_RLS` and defaults
to `*CURRENT`.

