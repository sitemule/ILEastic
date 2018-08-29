        dcl-ds  configDS qualified based(prototype_only);
            host    char(64);
            port    int(10);
            filler  char(4096);
        end-ds;

        dcl-ds requestDS qualified based(prototype_only);
            pConfig      pointer;
            pUrl         pointer;
            pQueryString pointer;
            pHeaders     pointer;
            pContent     pointer;
            contentType  char(128);
            method       varchar(32);

        end-ds;

        dcl-ds responseDS qualified based(prototype_only);
            pConfig     pointer;
            status      int(5);
            statusText  varchar(128);
            contentType varchar(128);
            charset     varchar(32) ;
        end-ds;

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
