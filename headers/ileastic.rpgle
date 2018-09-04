      /if defined (ILEASTIC)
      /eof
      /endif
      
      /define ILEASTIC
      
﻿        dcl-ds il_varchar qualified template;
            length int(10);
            string pointer;
        end-ds;
        
        dcl-ds il_config qualified template;
            host    varchar(64);
            port    int(10);
            filler  char(4096);
        end-ds;

        dcl-ds il_request qualified template;
            pConfig        pointer;
            method         likeds(il_varchar);
            url            likeds(il_varchar);
            resource       likeds(il_varchar);
            queryString    likeds(il_varchar);
            protocol       likeds(il_varchar);
            headers        likeds(il_varchar);
            content        likeds(il_varchar);
            contentType    varchar(128);
            completeHeader likeds(il_varchar);
        end-ds;

        dcl-ds il_response qualified template;
            pConfig     pointer;
            status      int(5);
            statusText  varchar(128);
            contentType varchar(128);
            charset     varchar(32) ;
        end-ds;

        dcl-pr il_getVarcharValue varchar(32760:4) ccsid(*utf8) rtnparm
                      extproc(*CWIDEN:'lvpc2lvc');
            input     likeds(il_varchar);    
        end-pr;

        dcl-pr il_listen extproc(*CWIDEN:'il_listen');
            config     likeds(il_config);
            servlet    pointer(*PROC) value;    
        end-pr;
        
        dcl-pr il_responseWrite extproc(*CWIDEN:'il_responseWrite');
            response   likeds(il_response);
            buf         varchar(32760:4) ccsid(*utf8) options(*varsize) const ;    
        end-pr;

        dcl-pr il_responseWriteBin extproc(*CWIDEN:'il_responseWrite');
            response   likeds(il_response);
            buffer     varchar(32760:4) options(*varsize) const ;    
        end-pr;

        dcl-pr il_serveStatic ind extproc(*CWIDEN:'il_serveStatic');
            response   likeds(il_response);
            fileName    varchar(256) options(*varsize) const;    
        end-pr;