        dcl-ds  configDS qualified based(prototype_only);
            host    char(64);
            port    int(10);
            filler  char(4096);
        end-ds;

        dcl-ds requestDS qualified based(prototype_only);
            pConfig     pointer;
            contentType char(128);
        end-ds;

        dcl-ds responseDS qualified based(prototype_only);
            pConfig     pointer;
            status      int(5);
            statusText  char(128);
            contentType char(128);
            charset     char(32) ;
        end-ds;

        dcl-pr node_listen extproc(*CWIDEN:'node_listen');
            pConfig     likeds(configDS);
            pServlet    pointer(*PROC) value;    
        end-pr;
        
        dcl-pr node_write extproc(*CWIDEN:'node_write');
            pResponse   likeds(responseDS);
            buf         varchar(32760) ccsid(*utf8) options(*varsize) const ;    
        end-pr;
