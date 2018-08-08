unit uwizardutil;

{$mode objfpc}{$H+}

interface

uses
  tiscommon,
  superobject,
  sysutils,
  Classes,
  IdCookieManager,
  dynlibs,
  waptcommon;

const



  WAPT_FIREWALL_RULE_HTTP  : String = 'waptserver http';
  WAPT_FIREWALL_RULE_HTTPS : String = 'waptserver https';


  MIME_APPLICATION_JSON : String = 'application/json';

{$define TIMEOUT_SERVICE_SEC 15}

type
  TShowLoadingFrameParams = record
    position  : integer;
    max       : integer;
    visible   : boolean;
    message   : String;
  end;
  PShowLoadingFrameParams = ^TShowLoadingFrameParams;

  TCreateSignedCertParams = record
    keyfilename           : UnicodeString;
    crtbasename           : UnicodeString;
    destdir               : UnicodeString;
    country               : UnicodeString;
    locality              : UnicodeString;
    organization          : UnicodeString;
    orgunit               : UnicodeString;
    commonname            : UnicodeString;
    keypassword           : UnicodeString;
    email                 : UnicodeString;
    codesigning           : Boolean;
    IsCACert              : Boolean;
    CACertificateFilename : UnicodeString;
    CAKeyFilename         : UnicodeString;

    _certificate          : String;
    _error_message        : String;
  end;
  PCreateSignedCertParams = ^TCreateSignedCertParams;

  TCreateSetupParams_waptagent = record
    default_public_cert       : Utf8String;
    default_repo_url          : Utf8String;
    default_wapt_server       : Utf8String;
    destination               : Utf8String;
    company                   : Utf8String;
    OnProgress                : TNotifyEvent;
    WaptEdition               : Utf8String;
    VerifyCert                : Utf8String;
    UseKerberos               : Boolean;
    CheckCertificatesValidity : Boolean;
    EnterpriseEdition         : Boolean;
    OverwriteRepoURL          : Boolean;
    OverwriteWaptServerURL    : Boolean;

    _agent_filename           : String;
    _err_message              : String;
    _result                   : integer;
  end;
  PCreateSetupParams_waptagent = ^TCreateSetupParams_waptagent;


  TCreateSetupParams_waptupgrade = record
    config_filename      : String;
    server_username      : String;
    server_password      : String;
    dualsign             : boolean;
    private_key_password : String;

    _filename             : String;
    _err_message          : String;
    _result               : integer;
  end;
  PCreateSetupParams_waptupgrade = ^TCreateSetupParams_waptupgrade;


  TProcedurePtrInt = procedure( data : PtrInt );

  { TObjectProcedureExecutor }

  TObjectProcedureExecutor = class
    m_proc : TProcedurePtrInt;
    m_free_after_execute : Boolean;
    constructor Create( p : TProcedurePtrInt );
    procedure execute( data : PtrInt );
  end;

  TRunParametersSync = record
    cmd_line    : String;
    timout_ms   : integer;
    on_run_tick : TNotifyEvent;
  end;
  PRunParamatersSync = ^TRunParametersSync;


function CreateSetupParams_waptagent(   params : PCreateSetupParams_waptagent   ): integer;
function CreateSetupParams_waptupgrade( params : PCreateSetupParams_waptupgrade ): integer;

function CreateSignedCertParams( params : PCreateSignedCertParams ) : integer;


function ServerCertificatSaveChain( var filename : String; const url : String; destdir : String ) : integer;
function check_key_password(key_filename: String; password: String): boolean;
function IdWget_is_404(const url: Utf8String;HttpProxy: String='';userAgent:String='';VerifyCertificateFilename:String='';CookieManager:TIdCookieManager=Nil): boolean;
function check_wapt_installation() : boolean;

function ensure_process_not_running( const process_name : String ) : boolean;


function sys_killall( const ExeFileName: string ) : integer;

function ExtractFileNameNoExt( filename : String ) : string;
function fs_path_exists( const path : String ) : boolean;
function fs_path_concat( const p1 : String; const p2 : String ) : String;
function fs_directory_is_writable( const path : String ): boolean;

function firewall_has_rule( const rulename : String ) : boolean;
function firewall_drop_rule( const rulename : String ) : boolean;
function firewall_is_running() : boolean;
function firewall_add_rule_allow( const name : String; local_port : UINT16 ) : boolean;

function  random_alphanum( size : integer ) : String;
procedure random_memset( p : pointer; sz : UInt32 );
function  random_server_uuid() : String;


function wapt_json_response_is_success( var success : boolean; const json : String ) : integer;


function url_force_protocol( const url : String; const protocol : String ) : String;
function url_concat( const left : String; const right : String ) : String;
function url_resolv_to_same_ip( var same : boolean; const url1 : String ; const url2 : String ) : integer;
function url_hostname( const url : String ) : String;
function url_protocol( var protocol : String; const url : String ) : integer;

function http_is_valid_url( const url : String ) : boolean;
function http_get( var output: String; const url: String): integer;
function http_post(var output: String; const url: String; const content_type : String; const post_data : String): integer;

function http_reponse_code( var response_code : integer; const url : String ) : integer;

function https_certificate_extract_hostname( var hostname : String; const https_url : String ) : integer;
function https_certificate_is_valid( var valid : boolean; const https_url: String ) : integer;
function https_certificate_is_pinned( var pinned : boolean; const https_url : String ) : integer;
function https_certificate_pin( const https_url : String ) : integer;
function https_certificate_pinned_filename( var filename : String; const https_url : String ) : integer;


function crypto_check_key_password(var success: boolean; const key_filename: String; const password: String): integer;


function process_launch( const binary : String; const params : PChar ) : integer;

function net_list_enable_ip( sl : TStringList ) : integer;




function wapt_server_firewall_is_configured( var is_configured : boolean ) : integer;
function wapt_server_configure_firewall( http_port : Int16; https_port : Int16 ) : integer;


function wapt_server_mongodb_to_postgresql() : integer;
function wapt_server_installation( var path : String ) : integer;
function wapt_installpath_waptservice( var path : String ) : integer;
function wapt_installpath_waptserver(var path: String): integer;
function wapt_console_install_path( var path : String ) : integer;

function wapt_register(): integer;



function sa_flip( const a : TStringArray ) : TStringArray;
function sa_concat( const a : TStringArray; const b : TStringArray ) : TStringArray;





function run_sync( params : PRunParamatersSync ) : integer;



procedure show_loading_frame_threadsafe( params : PShowLoadingFrameParams );
procedure hide_loading_frame_threadsafe();
function service_binary_path(var path: String; const service_name : String ): integer;


function thread_is_gui_thread() : boolean;


implementation

uses
  {$ifdef WINDOWS}
  waptwinutils,
  windows,
  win32proc,
  JwaWindows,
  {$endif}
  FileUtil,
  IdDNSResolver,
  PythonEngine,
  process,
  Forms,
  Controls,
  Dialogs,
  tisstrings,
  IdURI,
  IdHTTP,
  VarPyth,
  LazFileUtils,
  uvisloading,
  dmwaptpython,
  IdSSLOpenSSL,
  uwapt_services
  ;


const
  HTTP_TIMEOUT : integer = 4 * 1000;


function service_binary_path(var path: String; const service_name : String ): integer;
label
  LBL_FAILED;
var
   h_manager : SC_HANDLE;
   h_service : SC_HANDLE;
   lpsc      : LPQUERY_SERVICE_CONFIG;
   dwBytesNeeded : DWORD;
   s : String;
   b: BOOL;
   r : integer;
begin

  h_manager     := 0;
  h_service     := 0;
  lpsc          := nil;
  dwBytesNeeded := 0;

  h_manager:= OpenSCManager( nil, nil, SC_MANAGER_ALL_ACCESS );
  if h_manager = 0 then
    goto LBL_FAILED;

  s := service_name;
  SetLength(s, Length(s) + 1 );
  s[Length(s)] := #0;

  h_service := OpenService( h_manager, PChar(@s[1]), SERVICE_QUERY_CONFIG );
  if h_service = 0 then
    goto LBL_FAILED;

  b := QueryServiceConfig( h_service, nil, 0, dwBytesNeeded );
  if b then
    goto LBL_FAILED;
  lpsc := LPQUERY_SERVICE_CONFIG( GetMem(dwBytesNeeded));
  FillChar( lpsc^, dwBytesNeeded, 0 );

  b := QueryServiceConfig( h_service, lpsc, dwBytesNeeded, dwBytesNeeded );
  if not b then
    goto LBL_FAILED;

  path := lpsc^.lpBinaryPathName;

  Freemem(lpsc);
  CloseServiceHandle(h_service);
  CloseServiceHandle(h_manager);
  exit(0);

LBL_FAILED:
  if lpsc <> nil then
    Freemem(lpsc);

  if h_service <> 0 then
    CloseServiceHandle( h_service );
  if h_manager <> 0 then
  CloseServiceHandle( h_manager );

  exit(-1);
end;

function thread_is_gui_thread(): boolean;
begin
  result := MainThreadID = TThread.CurrentThread.ThreadID;
end;


function ensure_process_not_running( const process_name : String ) : boolean;
const
  SLEEP_TIME_BEFORE_RETRY_MS = 2 * 1000;
label
  LBL_START;
var
  msg : String;
  mr  : TModalResult;
begin
LBL_START:
  if not ProcessExists( process_name ) then
    exit( true );

  msg := Format(  'An instance of %s has been found.' + #13#10 +
                  'The program cannot continue unitl this process has terminated.' + #13#10 + #13#10 +
                  'Click on Yes to kill all the process named %s' + #13#10 +
                  'Click on Retry to recheck processes satus' + #13#10 +
                  'Click on Cancel to abort',
                  [process_name, process_name] );

  mr := MessageDlg(  'Error', msg, mtWarning, [mbYes,mbRetry,mbCancel], 0 );

  if mrCancel = mr then
    exit( false );

  if mrRetry = mr then
  begin
    Sleep( SLEEP_TIME_BEFORE_RETRY_MS );
    goto LBL_START;
  end;

  if mrYes = mr then
    result :=  sys_killall(process_name) = 0;

end;

function sys_killall( const ExeFileName: string ) : integer;
label
  LBL_FAILED;
const
  WAIT_TERMINATION_TIME_MS  = 5 * 1000;
  PROCESS_TERMINATE=$0001;
var
  b : WINBOOL;
  h_process_list: THandle;
  h_process : THandle;
  process_entry: TProcessEntry32;
  s : String;
begin

  result := 0;

  h_process := 0;
  h_process_list := 0;

  s := UpperCase(ExeFileName);

  h_process_list := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0);
  process_entry.dwSize := sizeof(TProcessEntry32);

  b := Process32First(h_process_list,process_entry);
  while integer(b) <> 0 do
  begin
    if s = UpperCase(process_entry.szExeFile) then
    begin
      h_process := OpenProcess( PROCESS_TERMINATE or SYNCHRONIZE, BOOL(0), process_entry.th32ProcessID);
      if h_process = 0 then
        goto LBL_FAILED;
      b := TerminateProcess( h_process, 1 );
      if b = WINBOOL(0) then
        goto LBL_FAILED;
      if WAIT_OBJECT_0 <> WaitForSingleObject( h_process, WAIT_TERMINATION_TIME_MS ) then
        goto LBL_FAILED;
      CloseHandle( h_process );
    end;
    b := Process32Next( h_process_list, process_entry );
  end;
  CloseHandle( h_process_list );

  exit(0);

LBL_FAILED:
  if h_process <> 0 then
    CloseHandle( h_process );
  if h_process_list <> 0 then
    CloseHandle( h_process_list );
  exit(-1);
end;


function ExtractFileNameNoExt( filename : String ) : string;
var
  i : integer;
  s : integer;
  e : integer;
  sz : integer;
begin
  sz := Length(filename);
  e := sz + 1;
  s := e;
  for i := sz downto 1 do
  begin
    if PathDelim = filename[i] then
      break
    else if '.' = filename[i] then
      e := i;
    s := i;
  end;

  e := e - s;
  if e = 0 then
    exit('');
  result := Copy( filename, s, e);
end;

function fs_path_exists(const path: String): boolean;
begin
  if FileExists( path ) then
      exit( true );
  if DirectoryExists( path ) then
      exit( true );

  exit( false );
end;

function fs_path_concat(const p1: String; const p2: String): String;
var
  s : integer;
  c : integer;
begin
  result := ExcludeTrailingPathDelimiter(p1);
  c := Length(p2);
  if c = 0 then
    exit;
  if p2[c] = PathDelim then
    c := c -1;

  s := 1;
  if p2[1] = PathDelim then
  begin
    s := 2;
    c := c -1;
  end;

  if c > 0 then
    result := result +  PathDelim + Copy( p2, s, c );
end;

function fs_directory_is_writable(const path: String): boolean;
var
  h : THandle;
  f : RawByteString;
begin

  if not DirectoryExists(path) then
    exit( false );

  repeat
    f := IncludeTrailingPathDelimiter(path) +  random_alphanum( 20 );
  until not FileExists(f);

  h := FileCreate(f);
  if h = THandle(-1) then
    exit( false );

  FileClose(h);

  if not DeleteFile( @f[1] ) then
    exit( false );

  exit(true);
end;


function random_alphanum( size: integer): String;
var
  i : integer;
  r : integer;
begin
  Randomize;
  SetLength( result, size );
  i := 1;

  while i <> size do
  begin
    // 48-57  Number
    // 65-90  Upper letters
    // 97-122 Lower letters
    case Random(3) of
      0 : r := 48 + Random(10);
      1 : r := 65 + Random(26);
      2 : r := 97 + Random(26);
    end;
    result[i] := Char(r);
    inc(i);
  end;

end;

procedure random_memset(p: pointer; sz: UInt32);
var
  i : integer;
begin
  for i := 0 to sz do
    UINT8( p^ ) := Random(255);
end;

function random_server_uuid(): String;
var
  s : String;
  GUID : TGUID;
begin
  s := random_alphanum(sizeof(TGuid));
  Move( s[1], GUID, sizeof(TGuid) );
  s := GUIDToString( GUID );
  result := Lowercase( Copy(s, 2, Length(s) - 2) );
end;


function wapt_json_response_is_success(var success: boolean; const json: String  ): integer;
var
  so : ISuperObject;
begin
  so := TSuperObject.ParseString( @WideString(json)[1], true );

  if not assigned( so ) then
    exit( -1 );

  so := so.O[ 'success' ];
  if not assigned( so ) then
      exit( -1 );

  if not (so.GetDataType = stBoolean) then
    exit( -1 );

  success := so.AsBoolean;
  exit( 0 );
end;



function IdWget_is_404(const url : Utf8String;HttpProxy: String='';userAgent:String='';VerifyCertificateFilename:String='';CookieManager:TIdCookieManager=Nil): boolean;
begin
  try
    IdWget_Try( url, HttpProxy, userAgent, VerifyCertificateFilename, CookieManager );
    exit( false );
  except on Ex : Exception do
    begin
      if Pos('404', ex.Message) = 0 then
        exit( false );
      exit( true );
    end;
  end;
end;

function check_wapt_installation(): boolean;
label
  LBL_FAIL;
var
  lh : TLibHandle;
begin
  lh := 0;

  lh := LoadLibrary('libopenssl.' + SharedSuffix);
  if lh = 0 then
    goto LBL_FAIL;
  FreeLibrary( lh );


  exit(true);

LBL_FAIL:
  if lh <> 0 then
    FreeLibrary( lh );
  exit(false);
end;


function CreateSignedCertParams(params: PCreateSignedCertParams): integer;
begin
  try
      params^._certificate := CreateSignedCert(
      params^.keyfilename,
      params^.crtbasename,
      params^.destdir,
      params^.country,
      params^.locality,
      params^.organization,
      params^.orgunit,
      params^.commonname,
      params^.email,
      params^.keypassword,
      params^.codesigning,
      params^.IsCACert,
      params^.CACertificateFilename,
      params^.CAKeyFilename
    );
    result := 0;
  except on Ex : Exception do
    begin
      params^._error_message := ex.Message;
      result := -1;
    end;
  end;
end;





function CreateSetupParams_waptagent( params: PCreateSetupParams_waptagent ): integer;
var
  agent : String;
begin
  params^._agent_filename :=  '';
  params^._err_message := '';


  agent := fs_path_concat( params^.destination, 'waptagent.exe' );
  if FileExists(agent) then
    DeleteFile(@agent[1]);
  agent := '';


  try
    agent  := UTF8Encode( CreateWaptSetup(
      params^.default_public_cert,
      params^.default_repo_url,
      params^.default_wapt_server,
      params^.destination,
      params^.company,
      params^.OnProgress,
      params^.WaptEdition,
      params^.VerifyCert,
      params^.UseKerberos,
      params^.CheckCertificatesValidity,
      params^.EnterpriseEdition,
      params^.OverwriteRepoURL,
      params^.OverwriteWaptServerURL
    ) );
    params^._agent_filename := agent;
    params^._result := 0;
    exit(0);

  except on Ex : Exception do
      params^._err_message := Ex.Message;
  end;

  params^._result := -1;
  exit(-1);
end;

function CreateSetupParams_waptupgrade(  params : PCreateSetupParams_waptupgrade ): integer;
var
  SignDigests : String;
  v: Variant;
  s : String;
  p : PShowLoadingFrameParams;
begin
  v := nil;



//  show_loading_frame_threadsafe( p );
  // Create waptupgrade package (after waptagent as we need the updated waptagent.sha1 file)
  SignDigests := 'sha256';
  if params^.dualsign then
    SignDigests := SignDigests + ',sha1';

  try
    //BuildResult is a PackageEntry instance
    v := DMPython.waptdevutils.build_waptupgrade_package(
      waptconfigfile    := params^.config_filename,
      wapt_server_user  := params^.server_username,
      wapt_server_passwd:= params^.server_password,
      key_password      := params^.private_key_password,
      sign_digests      := SignDigests
      );


    if not VarPyth.VarIsNone(v) and FileExistsUTF8(VarPythonAsString(v.get('localpath'))) then
    begin
      params^._filename := v.get('filename');
      s := VarPythonAsString( v.get('localpath') );
      DeleteFileUTF8( s );
      params^._result := 0;
    end
  except on ex : Exception do
    begin
      params^._err_message := ex.Message;
      params^._result := -1;
    end;
  end;

  if Assigned(VisLoading) then
    hide_loading_frame_threadsafe();

  exit( 0 );
end;








function check_key_password(key_filename: String; password: String): boolean;
var
  v : Variant;
begin
  try
    v := DMPython.waptcrypto.check_key_password( key_filename := key_filename, password := password );
    exit(PyVarToSuperObject(v).AsBoolean);
  except
    exit(false);
  end;
end;


function ServerCertificatSaveChain( var filename : String; const url : String; destdir : String ) : integer;
var
  cert_filename: String;
  cert_chain   : Variant;
  pem_data     : Variant;
  cert         : Variant;
begin
  try
    cert_chain := DMPython.waptcrypto.get_peer_cert_chain_from_server(url);
    pem_data   := DMPython.waptcrypto.get_cert_chain_as_pem(certificates_chain := cert_chain);
    if VarIsNone(pem_data) then
      exit(-1);
    cert  := cert_chain.__getitem__(0);
    cert_filename :=  IncludeTrailingPathDelimiter(destdir) + cert.cn + '.crt';
    if not DirectoryExists(destdir) then
      ForceDirectory(destdir);
    StringToFile(cert_filename, pem_data, false );
    filename := cert_filename;
    exit(0);
  except
    exit(-1);
  end;
end;


function url_force_protocol(const url: String; const protocol: String) : String;
var
  uri : TIdURI;
begin
  // Handling url even if only hostname is provided
  uri := TIdURI.Create( url );
  try
    uri.Protocol := protocol;
    result := protocol + '://';
    if Length(uri.Username) > 0 then
    begin
      result := result + uri.Username;
      if Length(uri.Password) > 0 then
        result := result + ':' + uri.Password;
      result := result + '@';
    end;
    result := result + uri.Host;
    result := result + uri.GetPathAndParams;
  finally
    uri.Free;
  end;
end;

function url_concat(const left: String; const right: String): String;
var
  r : integer;
begin
  result := left;

  if result[ Length(result) ] <> '/' then
    result := result + '/';

  r := length(right);
  if right[1] = '/' then
    result := result + Copy(right, 2, r - 1 )
  else
    result := result + right;
end;

function url_resolv_to_same_ip(var same: boolean; const url1: String;  const url2: String): integer;
var
  uri : TIdURI;
  s1 : String;
  s2 : String;
begin
  uri := nil;
  s1 := url_force_protocol( url1, 'p' );
  s2 := url_force_protocol( url2, 'p' );

  uri := TIdURI.Create();
  try
    uri.URI := s1;
    s1 := GetIPFromHost( uri.Host );

    uri.URI := s2;
    s2 := GetIPFromHost( uri.Host );

    uri.Free;

    same := s1 = s2;

    exit(0);
  except
  end;

  if Assigned(uri) then
    uri.Free;

  exit(-1);
end;

function url_hostname(const url: String): String;
var
  s : String;
  uri : TIdURI;
begin
  s := url_force_protocol( url, 'p' );
  uri := TIdURI.Create(s);
  result := uri.Host;
  uri.Free;
end;

function url_protocol(var protocol: String; const url: String): integer;
var
  i : integer;
begin
  i := Pos('://', url);
  if i = 0 then
    exit(-1);
  dec(i);
  protocol := Copy( url, 1, i );
  exit(0);
end;


function http_create( https : boolean ) : TIdHTTP;
var
  http : TIdHTTP;
  ssl  : TIdSSLIOHandlerSocketOpenSSL;
begin
  ssl := nil;

  http := TIdHTTP.Create;
  http.HandleRedirects  := True;
  http.ConnectTimeout   := HTTP_TIMEOUT;
  http.ReadTimeout      := HTTP_TIMEOUT;
  http.IOHandler        := nil;

  if https then
  begin
    ssl := TIdSSLIOHandlerSocketOpenSSL.Create;
    ssl.SSLOptions.Method := sslvSSLv23;
    http.IOHandler := ssl;
  end;


  result := http;
end;

procedure http_free( var http  : TIdHTTP );
begin
  if nil <> http.IOHandler then
  begin
    http.IOHandler.Free;
    http.IOHandler := nil;
  end;
  http.Free;
  http := nil;
end;



function http_is_valid_url(const url: String): boolean;
var
  proto : String;
  b_http : boolean;
  b_https : boolean;
begin
  if 0 <> url_protocol( proto, url) then
    exit( false );

  b_http := proto = 'http';
  b_https:= proto = 'https';

  result := b_http or b_https;
end;

function http_get(var output: String; const url: String ): integer;
var
  http : TIdHTTP;
  proto : String;
  b_http : boolean;
  b_https : boolean;
begin

  if not http_is_valid_url(url) then
  begin
    output := 'Invalid url';
    exit( -1 );
  end;

  url_protocol( proto, url );
  b_https:= proto = 'https';

  http := http_create( b_https );


  try
    output := http.Get( url );
    result := 0;
  except on E : Exception do
    begin
      result := -1;
      output := e.Message;
    end;
  end;

  http_free( http );

end;

function http_post(var output: String; const url: String; const content_type: String; const post_data: String): integer;
const
  proxy         : String    ='';
  user          : AnsiString='';
  password      : AnsiString='';
  userAgent     : String    ='';
  AcceptType    : String    ='';
  CookieManager : TIdCookieManager = Nil;
  VerifyCertificateFilename : String = '0';
begin

  if not http_is_valid_url(url) then
  begin
    output := 'Invalid url';
    exit( -1 );
  end;

  try
    output := IdHttpPostData( url,
                              post_data,
                              proxy,
                              HTTP_TIMEOUT,
                              HTTP_TIMEOUT,
                              HTTP_TIMEOUT,
                              user,
                              password,
                              userAgent,
                              content_type,
                              VerifyCertificateFilename,
                              AcceptType,
                              CookieManager );
    exit( 0 );
  except on e : Exception do
    begin
      output := e.Message;
      exit( -1 );
    end;
  end;
end;




function http_reponse_code(var response_code: integer; const url: String ): integer;
var
  http : TIdHTTP;
  proto : String;
  b_https : Boolean;
begin

  if not http_is_valid_url(url) then
    exit(-1);

  url_protocol( proto, url );
  b_https := proto = 'https';

  http := http_create( b_https );

  try
    http.Get(url);
  except
  end;

  if http.ResponseCode = -1 then
  begin
    http.Free;
    exit( -1 );
  end;


  response_code := http.ResponseCode;
  http.Free;
  exit(0);

end;



function https_certificat_option( verify : boolean; pinned_certificat_filename : String ) : String;
begin
  if verify = false then
    exit( '0' );

  pinned_certificat_filename := Trim(pinned_certificat_filename);
  if Length(pinned_certificat_filename) = 0 then
    exit('1');

  exit( pinned_certificat_filename );
end;


function https_certificate_extract_hostname( var hostname : String; const https_url : String ) : integer;
var
  v  : Variant;
  s : String;
begin
  if not Assigned(DMPython) then
    exit(-1);

  try
    v := DMPython.waptcrypto.get_peer_cert_chain_from_server( https_url );
    if VarIsNone( v ) then
      exit(-1);

    v := v.__getitem__(0);
    if VarIsNone(v) then
      exit(-1);

    v := v.cn;
    if VarIsNone(v) then
      exit(-1);

    s := v;
    s := trim(s);

    if Length(s) = 0 then
      exit(-1);

    hostname := s;
    exit(0);
  except
  end;
  exit(-1);
end;

function https_certificate_is_valid( var valid : boolean; const https_url: String ) : integer;
const
  proxy         : String = '';
  ConnectTimeout: integer= 4000;
  SendTimeOut   : integer= 60000;
  ReceiveTimeOut: integer= 60000;
  user          : String = '';
  password      : String = '';
  method        : String = 'GET';
  userAGent     : String = '';
  AcceptType    : String = '';
  CookieManager : TIdCookieManager = Nil;
var
  hostname  : String;
  r         : integer;
  certificat: String;
begin
  r := https_certificate_extract_hostname( hostname, https_url );
  if r <> 0 then
    exit( r );

  certificat := 'ssl/server/' + hostname + '.crt';
  if not FileExists( certificat ) then
    certificat := '1';

  try
    IdHttpGetString( https_url, proxy, ConnectTimeout, SendTimeOut, ReceiveTimeOut, user, password, method, userAGent, certificat, AcceptType, CookieManager );
    valid := true;
    exit( 0 );
  except
  end;
  valid := false;
  exit( 0 );
end;

function https_certificate_is_pinned( var pinned : boolean; const https_url : String ) : integer;
var
  hostname : String;
  r        : integer;
begin
  r := https_certificate_extract_hostname( hostname, https_url );
  if r <> 0 then
    exit( r );
  pinned := FileExists( 'ssl/server/' + hostname + '.crt' );
  exit( 0 );
end;

function https_certificate_pin( const https_url : String ) : integer;
var
  r : integer;
  f : String;
begin
  r := https_certificate_pinned_filename( f, https_url );
  if r <> 0 then
    exit( r );

  r := ServerCertificatSaveChain( f, https_url, 'ssl/server/' );
  if r <> 0 then
    exit( r );

  exit( 0 );
end;

function https_certificate_pinned_filename( var filename : String ; const https_url: String): integer;
var
  h : String;
  r : integer;
begin
  r := https_certificate_extract_hostname( h, https_url );
  if r <> 0 then
    exit( r );
  filename := h + '.crt';
  exit( 0 );
end;

function crypto_check_key_password(var success: boolean; const key_filename: String; const password: String): integer;
const
  _FAILED = -1;
  _TRUE   =  1;
  _FALSE  =  0;
var
  r : Variant;
  pe : TPythonEngine;
begin
  pe := GetPythonEngine();
  if not Assigned(pe) then
    exit(-1);

  try
    r := DMPython.waptcrypto.check_key_password( key_filename := key_filename, password := password );
  except
    exit(-1);
  end;

  if VarIsNone(r) then
    exit(-1);

  if not VarIsBool(r) then
    exit(-1);

  result := pe.PyObject_IsTrue( ExtractPythonObjectFrom(r));
  if _FAILED = result  then
    exit;

  success := _TRUE = result;
  exit(0);
end;

{$ifdef WINDOWS}
function process_launch(const binary: String; const params: PChar): integer;
var
  r       : HINST;
  msg     : String;
  wd      : String;
begin
{
  HINSTANCE ShellExecuteA(
  HWND   hwnd,
  LPCSTR lpOperation,
  LPCSTR lpFile,
  LPCSTR lpParameters,
  LPCSTR lpDirectory,
  INT    nShowCmd
);
  }
  wd := ExtractFilePath(binary);
  r := ShellExecute(0,'open',PChar(binary), params, PChar(wd), SW_SHOWNORMAL);
  if r < 32 then
  begin
    case r of
      0                     : msg := 'The operating system is out of memory or resources.';
      ERROR_FILE_NOT_FOUND  : msg := 'The specified file was not found.';
      ERROR_PATH_NOT_FOUND  : msg := 'The specified path was not found..';
      ERROR_BAD_FORMAT      : msg := 'The .exe file is invalid (non-Win32 .exe or error in .exe image)..';
      5                     : msg := 'The operating system denied access to the specified file..'; {SE_ERR_ACCESSDENIED}
      SE_ERR_ASSOCINCOMPLETE: msg := 'The file name association is incomplete or invalid..';
      SE_ERR_DDEBUSY        : msg := 'The DDE transaction could not be completed because other DDE transactions were being processed..';
      SE_ERR_DDEFAIL        : msg := 'The DDE transaction failed..';
      SE_ERR_DDETIMEOUT     : msg := 'The DDE transaction could not be completed because the request timed out..';
      32                    : msg := 'The specified DLL was not found..'; {SE_ERR_DLLNOTFOUND}
      SE_ERR_NOASSOC        : msg := 'There is no application associated with the given file name extension. This error will also be returned if you attempt to print a file that is not printable..';
      8                     : msg := 'There was not enough memory to complete the operation..'; {SE_ERR_OOM}
      SE_ERR_SHARE          : msg := 'A sharing violation occured.';
      else
        msg := Format('Unknow error %d', [r] );
    end;
    MessageDlg( Application.Name, msg, mtError, [mbOK], 0 );
    exit( -1 );
  end;

  exit(0);
end;
{$else}
function process_launch(const binary: String; const params: PChar): integer;
var
  p  : TProcess;
  sl : TStringList;
begin

  p := TProcess.Create( nil );
  p.Executable       := binary;
  p.CurrentDirectory := ExtractFilePath(binary);

  if Assigned(params) then
  begin
    sl := TStringList.Create;
    sl.Delimiter := ' ';
    sl.CommaText := params;
    p.Parameters.AddStrings( sl );
    sl.Free;
  end;

  try
    p.Execute;
    result := 0;
  Except on E : EProcess do
  begin
    MessageDlg( Application.Name, e.Message, mtError, [mbOK], 0 );
    result := -1;
  end;
  end;
  p.Free;
end;
{$endif}

{
/// windows
var
  ppQueryResultsSet : PDNS_RECORD;
  retvalue: Integer;
  res : AnsiString;
  ip,ips: ISuperObject;
begin
  Result := TSuperObject.Create(stArray);
  ppQueryResultsSet := Nil;
  retvalue := DnsQuery(
    PAnsiChar(name),
    DNS_TYPE_A,
    DNS_QUERY_BYPASS_CACHE or DNS_QUERY_NO_LOCAL_NAME or DNS_QUERY_NO_HOSTS_FILE,
    Nil,
    @ppQueryResultsSet,
    Nil);
}

function net_dns_server( var ip : String ) : integer;
label
  LBL_GETNETWORKPARAMS;
var
  fi : PFIXED_INFO;
  r  : DWORD;
  sz : ULONG;
  pip : PIP_ADDR_STRING;
begin
  fi := GetMem( sizeof(FIXED_INFO) );
  sz := sizeof(FIXED_INFO);

LBL_GETNETWORKPARAMS:
  r := GetNetworkParams( fi, sz );
  case r of

    ERROR_BUFFER_OVERFLOW:
    begin
      fi := ReAllocMem( fi, sz );
      goto LBL_GETNETWORKPARAMS;
    end;

    NO_ERROR:
    begin
      pip := fi^.DnsServerList.Next;
      if not Assigned(pip) then
      begin
        Freemem(fi);
        exit(0);
      end;
      ip := pip^.IpAddress.S;
      Freemem(fi);
      exit(0);
    end;

    else
      Freemem(fi);
      exit(-1);
  end;

end;


function net_dns_ptr( var hostname : String; const ipv4 : String ) : integer;
var

  DNS: TIdDNSResolver;
  I: Integer;
  j : integer;
  qr : TQueryResult;
  rr : TResultRecord;
  s : String;
begin
  DNS := TIdDNSResolver.Create(nil);
  DNS.WaitingTime := 5 * 1000;
  DNS.QueryType := [qtPTR];

  i := net_dns_server( s );
  if i <> 0then
    exit(-1);
  DNS.Host := s;
  try
    DNS.Resolve( ipv4 );
    for I := 0 to DNS.QueryResult.Count -1 do
    begin
      rr := DNS.QueryResult[i];
      if qtPTR <> rr.RecType then
        continue;
      hostname := TPTRRecord(rr).HostName;
      DNS.Free;
      exit(0);
    end;
  except on Ex : Exception do
  end;
  DNS.Free;
  exit(-1);
end;

function net_dns_ptr( var hostname : String; const psockaddrin : PSockAddrIn ) : integer;
var
  ip : String;
begin
  ip := inet_ntoa( psockaddrin^.sin_addr );
  result := net_dns_ptr( hostname, ip ) ;
end;


// unshamely stolen and adapted from http://forum.lazarus.freepascal.org/index.php/topic,24488.5/.html?PHPSESSID=5i1pqil9lmjsudk5vi1uc7a9e0
function net_list_enable_ip( sl: TStringList ): integer;
Var
    aSocket             : TSocket;
    aWSADataRecord      : WSAData;
    NoOfInterfaces      : Integer;
    NoOfBytesReturned   : DWORD;
    Buffer              : Array [0..30] of Interface_Info;
    i                   : Integer;
    ip                  : INT32;
    he                  : PHostEnt;
    r                   : integer;
    s                   : String;

    hostname            : String;
    hostname_ip         : INT32;
    hostname_ip_str     : String;
    so : ISuperObject;
Begin

  // Try resolve
  hostname := tiscommon.GetComputerName;
  s := GetDNSDomain;
  if Length(s) > 0 then
    hostname := hostname + '.' + s;
  hostname := LowerCase(hostname);
  so := DNSAQuery(hostname);
  if so.AsArray.Length = 1 then
  begin
    hostname_ip_str := so.AsArray[0].AsString;
    hostname_ip := IPV4ToInt( hostname_ip_str );
  end;





  // Startup of old the WinSock
  // WSAStartup ($0101, aWSADataRecord);

  // Startup of WinSock2
  WSAStartup(MAKEWORD(2, 0), aWSADataRecord);

  aSocket := Socket (AF_INET, SOCK_STREAM, 0);

  If (aSocket = INVALID_SOCKET) then
    exit(-1);

  Try
    If WSAIoctl (aSocket, SIO_GET_INTERFACE_LIST, NIL, 0, @Buffer, 1024, NoOfBytesReturned, NIL, NIL) = SOCKET_ERROR then
    begin
      CloseSocket (aSocket);
      WSACleanUp;
      exit(-1);
    end;

    NoOfInterfaces := NoOfBytesReturned  Div SizeOf (INTERFACE_INFO);

    // For each of the identified interfaces get:
    For i := 0 to NoOfInterfaces - 1 do
    Begin
      // Has flag up ?
      if IFF_UP <> ( IFF_UP and Buffer[i].iiFlags ) then
        continue;

      ip := INT32(  buffer[i].iiAddress.AddressIn.sin_addr );
      r := net_dns_ptr( s, @buffer[i].iiAddress.AddressIn );
      if r = 0 then
        sl.AddObject( s, TObject(ip) )
      else if hostname_ip = ip then
        sl.AddObject( hostname, TObject(hostname_ip)  )
      else
      begin
        s := inet_ntoa( in_addr(ip)  );
        sl.AddObject( s, TObject(ip) );
        continue;
      end;


    end;
    result := 0;

  Except
    result := -1;
  end;

  CloseSocket (aSocket);
  WSACleanUp;
  exit(0);
end;



{ TObjectProcedureExecutor }

constructor TObjectProcedureExecutor.Create( p : TProcedurePtrInt );
begin
  self.m_proc := p;
  self.m_free_after_execute := true;
end;

procedure TObjectProcedureExecutor.execute(data: PtrInt);
begin
  self.m_proc( data );
  if self.m_free_after_execute then
    Self.Free;
end;




{$ifdef WINDOWS}
function firewall_is_running() : boolean;
begin
  result := srv_is_running('MpsSvc');
end;

function firewall_has_rule( const rulename : String ) : boolean;
var
    s : String;
begin
  s := Format( 'netsh advfirewall firewall show rule name="%s"', [ rulename ] );
  try
    run( UTF8Decode(s) );
    exit( true );
  except
    exit( false );
  end;
end;

function firewall_drop_rule( const rulename : String ) : boolean;
var
    s : String;
begin
  s := Format( 'netsh advfirewall firewall delete rule "%s"', [ rulename ] );
  try
    run( UTF8Decode(s) );
    exit( true );
  except
    exit( false );
  end;
end;

function firewall_add_rule_allow( const name : String; local_port : UINT16 ) : boolean;
var
  params :  TRunParametersSync;
  r      : integer;
begin

  if not firewall_is_running() then
    exit;

  FillChar( params, sizeof(TRunParametersSync), 0 );
  params.cmd_line    := Format( 'netsh advfirewall firewall add rule name="%s" dir=in localport=%d protocol=TCP action=allow', [name, local_port] );
  params.timout_ms   := 3 * 1000;
  params.on_run_tick := nil;

  r := run_sync( @params );

  result := r = 0;
end;


function wapt_server_firewall_is_configured( var is_configured: boolean ): integer;
const
  SVC : String = 'MpsSvc';
var
    b : boolean;
    ss : TServiceState;
begin
  ss := GetServiceStatusByName( '', SVC );
  if ssStopPending = ss then
  begin
    srv_set_state( SVC, ssStopped, 5 );
    ss := GetServiceStatusByName( '', SVC );
  end;

  b  :=  ssStopped = ss;
  is_configured := b or (firewall_has_rule(WAPT_FIREWALL_RULE_HTTP) and firewall_has_rule(WAPT_FIREWALL_RULE_HTTPS));
  result := 0;
end;




function wapt_server_configure_firewall(http_port: Int16; https_port: Int16 ): integer;
var
   cmdline : String;
begin

  if not (ssRunning = GetServiceStatusByName( '', 'MpsSvc' )) then
    exit( 0 );

  firewall_drop_rule( WAPT_FIREWALL_RULE_HTTP );
  firewall_drop_rule( WAPT_FIREWALL_RULE_HTTPS );


  cmdline := Format( 'netsh advfirewall firewall add rule name="%s" dir=in localport=%d protocol=TCP action=allow', [WAPT_FIREWALL_RULE_HTTP, http_port] );
  Run( UTF8Decode(cmdline) );

  cmdline := Format( 'netsh advfirewall firewall add rule name="%s" dir=in localport=%d protocol=TCP action=allow', [WAPT_FIREWALL_RULE_HTTPS, https_port] );
  Run( UTF8Decode(cmdline) );

  exit(0);

end;
{$endif}

function wapt_server_mongodb_to_postgresql(): integer;
var
   install_path : String;
   s : String;
   r : integer;
begin

  r := wapt_installpath_waptserver( install_path );
  if r <> 0 then
    exit(r);

  s := IncludeTrailingBackslash(install_path) + '\waptserver\mongodb';
  if not DirectoryExists(s) then
    exit(0);

  run('waptpython.exe waptserver\waptserver_upgrade.py upgrade2postgres');

  if DirectoryExistsUTF8(s) then
     fileutil.DeleteDirectory(s, false);

  s := IncludeTrailingBackslash(install_path) + '\waptserver\mongodb';
  if DirectoryExistsUTF8(s) then
     fileutil.DeleteDirectory(s, false);

  exit(0);
end;

function wapt_server_installation(var path: String): integer;
label
  LBL_FAILED;
const
  SERVICE_WAPTSERVER : String = 'WAPTServer';
var
   h_manager : SC_HANDLE;
   h_service : SC_HANDLE;
   lpsc      : LPQUERY_SERVICE_CONFIG;
   dwBytesNeeded : DWORD;
   s : String;
   b: BOOL;
   r : integer;
begin

  h_manager     := 0;
  h_service     := 0;
  lpsc          := nil;
  dwBytesNeeded := 0;

  h_manager:= OpenSCManager( nil, nil, SC_MANAGER_ALL_ACCESS );
  if h_manager = 0 then
    goto LBL_FAILED;

  s := SERVICE_WAPTSERVER;
  SetLength(s, Length(s) + 1 );
  s[Length(s)] := #0;

  h_service := OpenService( h_manager, PChar(@s[1]), SERVICE_QUERY_CONFIG );
  if h_service = 0 then
    goto LBL_FAILED;

  b := QueryServiceConfig( h_service, nil, 0, dwBytesNeeded );
  if b then
    goto LBL_FAILED;
  lpsc := LPQUERY_SERVICE_CONFIG( GetMem(dwBytesNeeded));
  FillChar( lpsc^, dwBytesNeeded, 0 );

  b := QueryServiceConfig( h_service, lpsc, dwBytesNeeded, dwBytesNeeded );
  if not b then
    goto LBL_FAILED;


  s := String(lpsc^.lpBinaryPathName);
  r := Pos( 'waptservice', s );
  if r = 0 then
    goto LBL_FAILED;

  s := Copy( s, 1, r -1 );
  path := ExcludeTrailingBackslash(s);

  Freemem(lpsc);
  CloseServiceHandle(h_service);
  CloseServiceHandle(h_manager);
  exit(0);

LBL_FAILED:
  if lpsc <> nil then
    Freemem(lpsc);

  if h_service <> 0 then
    CloseServiceHandle( h_service );
  if h_manager <> 0 then
  CloseServiceHandle( h_manager );

  exit(-1);
end;


function wapt_installpath_waptserver(var path: String): integer;
var
  r : integer;
  s : String;
begin
    r := service_binary_path( s, WAPT_SERVICE_WAPTSERVER );
  if r <> 0 then
    exit(r);
  r := Pos( 'waptservice', s );
  if r = 0 then
    exit(-1);
  path := Copy( s, 1, r - 1);
  exit(0);
end;



function wapt_installpath_waptservice(var path: String): integer;
var
  r : integer;
  s : String;
begin
  r := service_binary_path( s, WAPT_SERVICE_WAPTSERVICE );
  if r <> 0 then
    exit(r);
  r := Pos( 'waptservice', s );
  if r = 0 then
    exit(-1);
  path := Copy( s, 1, r - 1);
  exit(0);
end;






function sa_flip(const a: TStringArray): TStringArray;
var
  i : integer;
  j : integer;
begin
  SetLength( result, Length(a) );
  j := 0;
  for i := Length(a) -1  downto 0 do
  begin
    Result[j] := a[i];
    inc(j);
  end;

end;

function sa_concat( const a: TStringArray; const b: TStringArray): TStringArray;
var
  i : integer;
  o : integer;
  la : integer;
  lb : integer;
begin
  la := Length(a);
  lb := Length(b);

  SetLength( result, la + lb );

  la := la -1;
  lb := lb -1;

  for i := 0 to la  do
    result[i] := a[i];

  o := la + 1;
  for i := 0 to lb do
    result[o+i] := b[i];

end;

function readfile_available( h : THandle; buffer : PDWORD; buffer_size : integer ) : integer;
var
  bytes_available: DWORD;
  bytes_readed   : DWORD;
  b : BOOL;
begin
  b := PeekNamedPipe( h, nil, 0, nil, @bytes_available, nil );
  if not b then
    exit(-1);

  if bytes_available = 0 then
    exit(0);

  b := ReadFile( h, buffer, bytes_available, @bytes_readed, nil );
  if not b then
    exit(-1);

  exit( bytes_readed )
end;

function run_sync( params : PRunParamatersSync ) : integer;
label
  LBL_FAIL;
const
  I  : integer = 0;
  O  : integer = 1;
  E  : integer = 2;
  R  : integer = 0;
  W  : integer = 1;
  WAIT_DURATION : integer = 15;
  BUFFER_SIZE  = 4096;
var
  sa : SECURITY_ATTRIBUTES;
  si : STARTUPINFO;
  pi : PROCESS_INFORMATION;
  b  : BOOL;
  dw : DWORD;
  buffer : array[0..BUFFER_SIZE-1] of DWORD;
  ss : TStringStream;
  handles : array[0..2, 0..1] of THandle;
  rr : integer;

  procedure __process_pipes();
  begin
    // Read output
    rr := readfile_available( handles[O,R], buffer, BUFFER_SIZE );
    if rr > 0 then
      ss.Write( buffer, rr );

    // Read eror
    rr := readfile_available( handles[E,R], buffer, BUFFER_SIZE );
    if rr > 0 then
      ss.Write( buffer, rr );

    if Assigned( params^.on_run_tick ) then
      params^.on_run_tick( TObject(ss) );
  end;

begin

  ss := nil;

  //
  FillChar( handles, sizeof(THandle) * 6, 0 );
  FillChar( pi, sizeof(PROCESS_INFORMATION), 0 );

  //
  FillChar( sa, sizeof(SECURITY_ATTRIBUTES), 0 );
  sa.nLength := sizeof(SECURITY_ATTRIBUTES);
  sa.bInheritHandle := TRUE;

  CreatePipe( handles[I,R], handles[I,W], @sa, 0 );
  CreatePipe( handles[O,R], handles[O,W], @sa, 0 );
  CreatePipe( handles[E,R], handles[E,W], @sa, 0 );

  //
  FillChar( si, sizeof(STARTUPINFO), 0 );
  si.cb           := sizeof(STARTUPINFO);
  si.dwFlags      := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  si.wShowWindow  := SW_HIDE;
  si.hStdInput    := handles[I,R];
  si.hStdOutput   := handles[O,W];
  si.hStdError    := handles[E,W];

  UniqueString( params^.cmd_line );
  b := CreateProcess( nil, @params^.cmd_line[1], nil, nil, True, CREATE_NEW_CONSOLE, nil, nil, si, pi );
  if not b then
    goto LBL_FAIL;

  CloseHandle( handles[I,R] );
  CloseHandle( handles[O,W] );
  CloseHandle( handles[E,W] );

  ss := TStringStream.Create('');
  while (params^.timout_ms > 0) do
  begin

    __process_pipes();

    dw := WaitForSingleObject( pi.hProcess, WAIT_DURATION );
    if WAIT_TIMEOUT = dw then
      dec( params^.timout_ms, WAIT_DURATION )
    else if WAIT_OBJECT_0 = dw then
      break
    else
      goto LBL_FAIL;

  end;

  // Terminate process
  if params^.timout_ms < 1 then
    TerminateProcess( pi.hProcess, UINT(ERROR_CANCELLED) );


  __process_pipes();

  b := GetExitCodeProcess(pi.hProcess, &dw);



  CloseHandle( handles[I,W] );
  CloseHandle( handles[O,R] );
  CloseHandle( handles[E,R] );

  FreeAndNil(ss);

  if b then
    exit(dw);

  exit(0);

LBL_FAIL:
  if Assigned(ss) then
    ss.Free;

  if pi.hProcess <> 0 then
    TerminateProcess( pi.hProcess, UINT(ERROR_CANCELLED) );

  CloseHandle( handles[I,R] );
  CloseHandle( handles[I,W] );
  CloseHandle( handles[O,R] );
  CloseHandle( handles[O,W] );
  CloseHandle( handles[E,R] );
  CloseHandle( handles[E,W] );

  exit( -1 );
end;



procedure _show_loading_frame_threadsafe( data : PtrInt );
var
  ope    : TObjectProcedureExecutor;
  params : PShowLoadingFrameParams;
begin

  if not Assigned( Pointer(data) ) then
    exit;

  if TThread.CurrentThread.Handle <> 0 then
  begin
    ope := TObjectProcedureExecutor.Create( @_show_loading_frame_threadsafe );
    Application.QueueAsyncCall( @ope.execute, data );
    exit;
  end;

  if not assigned( VisLoading ) then
    VisLoading := TVisLoading.Create( nil );

  params := PShowLoadingFrameParams( data );

  if params^.position <> -1 then
    VisLoading.AProgressBar.Position := params^.position;

  if params^.max <> -1 then
    VisLoading.AProgressBar.Max := params^.max;

  if Length(params^.message) <> 0 then
    VisLoading.AMessage.Caption := params^.message;

  VisLoading.Visible:= params^.visible;
  if not VisLoading.Visible then
    FreeAndNil( VisLoading );

  Freemem( params );

end;

procedure show_loading_frame_threadsafe( params : PShowLoadingFrameParams );
begin
  _show_loading_frame_threadsafe( PtrInt(params) );
end;

procedure hide_loading_frame_threadsafe();
var
  params : PShowLoadingFrameParams;
begin
  params := GetMem( sizeof(TShowLoadingFrameParams) );
  FillChar( params^, sizeof(TShowLoadingFrameParams), 0 );
  params^.visible := false;
  _show_loading_frame_threadsafe( PtrInt(params) );
end;

function wapt_console_install_path(var path: String): integer;
var
  s : String;
  r : integer;
  o : TObject;
begin
  r := wapt_server_installation( s );
  if r = 0 then
  begin
    if FileExists(IncludeTrailingBackslash(s) + 'waptconsole.exe') then
    begin
      path := s;
      exit(0);
    end;
  end;

  o := nil;
  o.Destroy;

end;

function wapt_register(): integer;
const
  TIMEOUT_MS = 15 * 1000;
var
  params : TRunParametersSync;
  r : integer;
  cmdlines  : array of String;
  i : integer;
begin

  SetLength( cmdlines, 2);
  cmdlines[0] := 'wapt-get.exe --direct register';
  cmdlines[1] := 'wapt-get.exe --direct update';

  for i := 0 to Length(cmdlines) -1 do
  begin
    params.cmd_line    := cmdlines[i];
    params.on_run_tick := nil;
    params.timout_ms   := TIMEOUT_MS;
    r := run_sync( @params );
    if r <> 0 then
      exit(r);
  end;

  exit(0);
end;





end.

