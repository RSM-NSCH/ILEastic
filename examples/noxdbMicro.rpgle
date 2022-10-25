**FREE

///
// Integration to noxDB - Note it requires the NOXDB installed
// You need to run the SQL scripts in "demo.sql" by ACS to have the test data
//
//
// Start it:
// ADDLIBLE ILEASTIC
// SBMJOB CMD(CALL PGM(NOXDBMICRO)) JOB(NOXDBMICRO) JOBQ(QSYSNOMAX)  ALWMLTTHD(*YES)        
// 
// The web service can be tested with the browser by entering the following URL:
// http://myibmi:44001/getuserbyview
// http://myibmi:44001/getuserbyproc
//
// @info: It requires your RPG code to be reentrant and compiled for 
//        multithreading. Each client request is handled by a seperate thread.
///
   
ctl-opt copyright('Sitemule.com  (C), 2018');
ctl-opt decEdit('0,') datEdit(*YMD.) ;
ctl-opt debug(*yes) bndDir('ILEASTIC':'NOXDB');
ctl-opt thread(*CONCURRENT);
ctl-opt main(main);


/include ./headers/ILEastic.rpgle
/include ./noxdb/headers/jsonParser.rpgle

// -----------------------------------------------------------------------------
// Program Entry Point
// -----------------------------------------------------------------------------     
dcl-proc main;

    dcl-ds config likeds(IL_CONFIG);
    config.port = 44001; 
    config.host = '*ANY';

    // The request end point is an regular expression: 
    // ^ means that a matching request must start here
    // $ means that a matching request must end here
    //
    // This means that if you have a match this routing code will 
    // call the procedure assigned to the endpoint. All other 
    // end points will return 404 NOT FOUND.
    il_addRoute(config : %paddr(getUserByView) : IL_ANY : 'getuserbyview');
    il_addRoute(config : %paddr(getUserByProc) : IL_ANY : 'getuserbyproc');
    il_addRoute(config : %paddr(hello) : IL_ANY : 'hello');
    il_addRoute(config : %paddr(huge) : IL_ANY : 'huge');
  
    il_listen(config);

end-proc;

// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc getUserByView;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;

    // Assume everything is OK
    response.status = 200;
    response.contentType = 'application/json';

    // Use noxDB to produce a JSON resultset to return
    pResult = json_sqlResultSet ('-
        select * from microdemo.users_full-
    ');

    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWriteStream(response : json_stream( pResult));

    json_delete(pResult);


end-proc;
// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc getUserByProc;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;
    dcl-s search  varchar(64);

    // Assume everything is OK
    response.status = 200;
    response.contentType = 'application/json';

    search = il_getParmStr(request : 'search');

    // Use noxDB to produce a JSON resultset to return
    pResult = json_sqlResultSet ('-
        call microdemo.user_list (search => ''' + search + ''') -
    ');

    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWriteStream(response : json_stream( pResult));
    json_delete(pResult);



end-proc;
// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc hello;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;
    dcl-s name  varchar(64);

    // Assume everything is OK
    response.status = 200;
    response.contentType = 'text/plain';

    name = il_getParmStr(request : 'name');

   
    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWrite (response : 'hello  ' + name);


end-proc;
// -----------------------------------------------------------------------------
// Servlet callback implementation
// -----------------------------------------------------------------------------     
dcl-proc huge;

    dcl-pi *n;
        request  likeds(IL_REQUEST);
        response likeds(IL_RESPONSE);
    end-pi;

    dcl-s pResult pointer;

    // Assume everything is OK
    response.status = 200;
    response.contentType = 'application/json';

    // Use noxDB to produce a JSON resultset to return
    pResult = json_sqlResultSet ('-
        select * from qsys2.systables -
    ');

    // Use the stream to input data from noxdb and output it to ILEastic 
    il_responseWriteStream(response : json_stream( pResult));

    json_delete(pResult);


end-proc;
