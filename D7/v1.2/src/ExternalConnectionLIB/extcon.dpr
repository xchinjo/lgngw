library extcon;
{ HOSxP External Connection for MySQL Library. }

uses
  SysUtils,Forms,ActiveX,
  Dialogs,
  Classes,
  DB,
  DBAccess,
  MyAccess,
  DBClient,
  Provider,
  MemDS,
  uCiaXml in '..\LIB\uCiaXml.pas';

{$R *.res}


const
_config_file ='gwconfig.xml';
_sample_db='dba0';

function initMyConnection(conn:TMyConnection):boolean;
var rep:boolean;
xmlConn : TXMLConfig;
_app_address,_app_hostname,_app_database,_app_user,_app_password:string;
begin
  try
    //InputBox('','','ExtConn');
    rep:=false;
    xmlConn:=TXMLConfig.Create(ExtractFilePath(Application.ExeName)+_config_file);
    //xmlConn:=TXMLConfig.Create(_config_file);
    if (xmlConn.ReadString('ExtConfig','ADDRESS','')='') then
    begin
        // mssql connection
        xmlConn.WriteString('ExtConfig','ADDRESS','localhost');
        xmlConn.WriteString('ExtConfig','HOSTNAME','www.hosxp.net');
        xmlConn.WriteString('ExtConfig','USER','root');
        xmlConn.WriteString('ExtConfig','PASSWORD','123456');
        xmlConn.WriteString('ExtConfig','DATABASE',_sample_db);
        xmlConn.Save;
    end;

     _app_address:= xmlConn.ReadString('ExtConfig','ADDRESS','');
     _app_hostname:= xmlConn.ReadString('ExtConfig','HOSTNAME','');
     _app_database:=xmlConn.ReadString('ExtConfig','DATABASE','');
     _app_user:=xmlConn.ReadString('ExtConfig','USER','root');
     _app_password:=xmlConn.ReadString('ExtConfig','PASSWORD','123456');

     with conn do
     begin
      Connected:=false;
      Database:=_app_database;
      Password:=_app_password;
      Server:= _app_address;
      Username:= _app_user;
      Options.Charset:='tis620';

      Connected:=true;
      rep:=true;
     end;
     xmlConn.Free;
  except
    on err:Exception do
    begin
      rep:=false;
      MessageDlg(err.Message,mtError,[mbOK],0);
      ShowMessage('Can not connect to Gateway database!!'+#10#13+_app_address+'-'+_app_database+'-'+_app_user+'-'+_app_password);
    end;
  end;

  result:=rep;

end;



function HOSxP_extUpdateDelta(Delta: OleVariant; SQLText: string): Integer;
var
  conn : TMyConnection;
  lQuery: TMyQuery;

  lDSP: TDataSetProvider;
  lError: Integer;
  lQue: Integer;

  DeadLockDetected: boolean;
begin

  Conn := TMyConnection.Create(nil);

  {
  conn.Username :='root';
  conn.Password :='123456';
  conn.Server :='127.0.0.1';
  Conn.Port:=3306;
  Conn.Database:='dba0';
  conn.Connected:=true;
  }
  initMyConnection(conn);

  lQuery := TMyQuery.Create(nil);

  lQuery.paramcheck := false;
  lQuery.Connection := conn;

  lDSP := TDataSetProvider.Create(nil);

  try

    SQLText := stringreplace(stringreplace(SQLText, '"', '''', [rfreplaceall]),
      '^^', '"', [rfreplaceall]);

//  InputBox('','',SQLText);

    lQuery.SQL.Text := SQLText;
    lDSP.DataSet := lQuery;
    lDSP.resolvetodataset := false;
    lDSP.updatemode := upWherekeyonly;

    lDSP.ApplyUpdates(Delta, -1, lError);

    if lError > 0 then
    begin

      lQuery.close;
      lQuery.open;
      lDSP.resolvetodataset := true;
      lDSP.updatemode := upWhereall;

      lDSP.ApplyUpdates(Delta, -1, lError);

    end;

  finally
    lDSP.Free;
    lQuery.Free;
    conn.Free;
  end;
  Result := lError;

end;

function HOSxP_extGetDataSet(const SQL: string): Variant;stdcall;
var
  Conn : TMyConnection ;
  lQuery: TMyQuery;

  lDSP: TDataSetProvider;
  lError: Integer;
  lQue: Integer;

  CanExecute: boolean;
  recsout: Integer;
  DeadLockDetected: boolean;
  errmsg: string;
begin

  //repeat
    try
      try
        DeadLockDetected := false;
        errmsg := '';
        CanExecute := false;
        if pos('UPDATE', trim(uppercase(SQL))) = 1 then
          CanExecute := true;

        if pos('SET', trim(uppercase(SQL))) = 1 then
          CanExecute := true;

        if pos('DROP', trim(uppercase(SQL))) = 1 then
          CanExecute := true;
        if pos('CREATE', trim(uppercase(SQL))) = 1 then
          CanExecute := true;
        if pos('ALTER', trim(uppercase(SQL))) = 1 then
          CanExecute := true;
        if not CanExecute then
          if pos('DELETE', trim(uppercase(SQL))) = 1 then
            CanExecute := true;

        if not CanExecute then
          if pos('INSERT', trim(uppercase(SQL))) = 1 then
            CanExecute := true;

        if not CanExecute then
          if pos('CREATE', trim(uppercase(SQL))) = 1 then
            CanExecute := true;

        if not CanExecute then
          if pos('TRUNCATE', trim(uppercase(SQL))) = 1 then
            CanExecute := true;


        Conn := TMyConnection.Create(nil);
        {
        conn.Username :='root';
        conn.Password :='123456';
        conn.Server :='127.0.0.1';
        Conn.Port:=3306;
        Conn.Database:='dba0';
        }
        initMyConnection(conn);

        lDSP := TDataSetProvider.Create(nil);

        try

          lQuery := TMyQuery.Create(nil);

          lQuery.Connection := conn;

          lQuery.SQL.Text := stringreplace(SQL, '"', '''', [rfreplaceall]);

          lQuery.paramcheck := false;
          lDSP.DataSet := lQuery;

          if CanExecute then
            lQuery.execute;

          if not CanExecute then

            Result := lDSP.GetRecords(-1, recsout, MetaDataOption);

        finally

          lDSP.Free;

          lQuery.Free;
          Conn.Free;

        end;

      finally

      end;
    except
      on e: exception do
      begin
        if pos('Deadlock', e.message) > 0 then
          DeadLockDetected := true
        else
          errmsg := e.message;
      end;
    end;
 // until not DeadLockDetected;
  if errmsg <> '' then
    raise exception.Create(errmsg);
end;





{
var Conn : TMyConnection ;
    qry: TMyQuery;
    dsp  : TDataSetProvider;
begin
  Conn := TMyConnection.Create(nil);
  conn.Username :='root';
  conn.Password :='123456';
  conn.Server :='127.0.0.1';
  Conn.Port:=3306;
  Conn.Database:='hos';

  try
    conn.Connected:=true;

    qry := TMyQuery.Create(nil);
    qry.Connection := Conn;

    dsp := TDataSetProvider.Create(nil);
    dsp.Name := 'dsp'+_dataset.Name;
    dsp.DataSet := qry;

    //_dataset.ProviderName := 'dsp'+_dataset.Name;

    //InputBox('','',_dataset.ProviderName);

    qry.SQL.Text:='select * from clinic';
    qry.Open;
    InputBox('','',IntToStr(qry.RecordCount));

  except

  end;



end;

}

function HOSxP_extVersionInfo():integer;
begin
  result := 5602001;
end;

exports
  HOSxP_extGetDataSet,HOSxP_extUpdateDelta,HOSxP_extVersionInfo;





begin
CoInitialize(nil);
end.
