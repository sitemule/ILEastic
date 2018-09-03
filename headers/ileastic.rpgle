        dcl-ds  LVARPUCHARDS  qualified based(prototype_only);
            Length  int(10);
            String  pointer;
        end-ds;
        
        dcl-ds  configDS qualified based(prototype_only);
            host    varchar(64);
            port    int(10);
            filler  char(4096);
        end-ds;

        dcl-ds requestDS qualified based(prototype_only);
            pConfig        pointer;
            method         likeds(LVARPUCHARDS);
            url            likeds(LVARPUCHARDS);
            resource       likeds(LVARPUCHARDS);
            queryString    likeds(LVARPUCHARDS);
            protocol       likeds(LVARPUCHARDS);
            headers        likeds(LVARPUCHARDS);
            content        likeds(LVARPUCHARDS);
            contentType    varchar(128);
            completeHeader likeds(LVARPUCHARDS);
        end-ds;

        dcl-ds responseDS qualified based(prototype_only);
            pConfig     pointer;
            status      int(5);
            statusText  varchar(128);
            contentType varchar(128);
            charset     varchar(32) ;
        end-ds;

        dcl-pr lCopy  varchar(32760:4) ccsid(*utf8) rtnparm
                      extproc(*CWIDEN:'lvpc2lvc');
            input     likeds(LVARPUCHARDS);    
        end-pr;

        dcl-pr il_listen extproc(*CWIDEN:'il_listen');
            pConfig     likeds(configDS);
            pServlet    pointer(*PROC) value;    
        end-pr;
        
        dcl-pr il_responseWrite extproc(*CWIDEN:'il_responseWrite');
            pResponse   likeds(responseDS);
            buf         varchar(32760:4) ccsid(*utf8) options(*varsize) const ;    
        end-pr;

        dcl-pr il_responseWriteBin extproc(*CWIDEN:'il_responseWrite');
            pResponse   likeds(responseDS);
            buf         varchar(32760:4) options(*varsize) const ;    
        end-pr;

        dcl-pr il_serveStatic ind extproc(*CWIDEN:'il_serveStatic');
            pResponse   likeds(responseDS);
            fileName    varchar(256) options(*varsize) const;    
        end-pr;
