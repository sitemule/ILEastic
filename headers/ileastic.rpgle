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
            contentType    varchar(256);
            completeHeader likeds(LVARPUCHARDS);
        end-ds;

        dcl-ds responseDS qualified based(prototype_only);
            pConfig     pointer;
            status      int(5);
            statusText  varchar(256);
            contentType varchar(256);
            charset     varchar(32) ;
        end-ds;

        dcl-pr lCopy    varchar(524284:4) ccsid(*utf8) rtnparm
                        extproc(*CWIDEN:'lvpc2lvc');
            input       likeds(LVARPUCHARDS);    
        end-pr;


        dcl-pr il_getRequestMethod  varchar(256:2) ccsid(*utf8) rtnparm
                        extproc(*CWIDEN:'il_getRequestMethod');
            pRequest likeds(RequestDS);    
        end-pr;

        dcl-pr il_getRequestUrl  varchar(524284:4) ccsid(*utf8) rtnparm
                        extproc(*CWIDEN:'il_getRequestUrl');
            pRequest likeds(RequestDS);    
        end-pr;

        dcl-pr il_getRequestResource  varchar(524284:4) ccsid(*utf8) rtnparm
                        extproc(*CWIDEN:'il_getRequestResource');
            pRequest likeds(RequestDS);    
        end-pr;

        dcl-pr il_getRequestQueryString  varchar(524284:4) ccsid(*utf8) rtnparm
                        extproc(*CWIDEN:'il_getRequestQueryString');
            pRequest likeds(RequestDS);    
        end-pr;

        dcl-pr il_getRequestProtocol  varchar(256:2)  ccsid(*utf8) rtnparm
                        extproc(*CWIDEN:'il_getRequestProtocol');
            pRequest likeds(RequestDS);    
        end-pr;

        dcl-pr il_getRequestHeaders  varchar(524284:4)  ccsid(*utf8) rtnparm
                        extproc(*CWIDEN:'il_getRequestHeaders');
            pRequest likeds(RequestDS);    
        end-pr;

        dcl-pr il_getRequestHeader  varchar(524284:4)  ccsid(*utf8) rtnparm
                        extproc(*CWIDEN:'il_getRequestHeader');
            pRequest likeds(RequestDS); 
            header   pointer value options(*string);   
        end-pr;

        dcl-pr il_getContent  varchar(524284:4)  ccsid(*utf8) rtnparm
                        extproc(*CWIDEN:'il_getContent');
            pRequest likeds(RequestDS);    
        end-pr;

        dcl-pr il_getFileMimeType  varchar(256:2)  rtnparm
                        extproc(*CWIDEN:'il_getFileMimeType');
            fileName    varchar(256:2);    
        end-pr;

        dcl-pr il_getFileExtension  varchar(256:2)  rtnparm
                        extproc(*CWIDEN:'il_getFileExtension');
            fileName    varchar(256:2);    
        end-pr;

        dcl-pr il_listen extproc(*CWIDEN:'il_listen');
            pConfig     likeds(configDS);
            pServlet    pointer(*PROC) value;    
        end-pr;
        
        dcl-pr il_responseWrite extproc(*CWIDEN:'il_responseWrite');
            pResponse   likeds(responseDS);
            buf         varchar(524284:4) ccsid(*utf8) options(*varsize) const ;    
        end-pr;

        dcl-pr il_responseWriteBin extproc(*CWIDEN:'il_responseWrite');
            pResponse   likeds(responseDS);
            buf         varchar(524284:4) options(*varsize) const ;    
        end-pr;

        dcl-pr il_serveStatic ind extproc(*CWIDEN:'il_serveStatic');
            pResponse   likeds(responseDS);
            fileName    varchar(256) options(*varsize) const;    
        end-pr;

        dcl-pr il_responseWriteStream extproc(*CWIDEN:'il_responseWriteStream');
            pResponse   likeds(responseDS);
            pStream     pointer value; // Pointer returned by i.e. json_stream from noxDB
        end-pr;


