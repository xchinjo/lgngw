library hosxpcon;
{ HOSxP Connection  Library. }

uses
  SysUtils,
  Forms,
  Activex,
  Dialogs,
  Classes,
  DB,
  DBAccess,
  MyAccess,
  DBClient,
  Provider,
  MemDS,
  uCiaXml in '..\LIB\uCiaXml.pas',
  MyXML in '..\LIB\MyXML.pas';

{$R *.res}

const
_config_file ='gwconfig.xml';
_sample_db='dba_19022013';

//var
 // _OnSQL : TOnSQLEvent;

function initMyConnection(conn:TMyConnection):boolean;

var
  rep:boolean;
  Xml: TMyXml;
  Node, Child, SubChild: TXmlNode;
  _app_address,_app_hostname,_app_database,_app_user,_app_password:string;
begin
  try
    rep := false;
    if not FileExists(ExtractFilePath(Application.ExeName)+_config_file) then
    begin

      Xml := TMyXml.Create;
      Xml.Header.Attribute['encoding'] := 'utf-8';


      Xml.Root.NodeName := 'Configuration';
      Node := Xml.Root.AddChild('HOSxPConfig');
      SubChild := Node.AddChild('ADDRESS');SubChild.Text := 'localhost';
      SubChild := Node.AddChild('HOSTNAME');SubChild.Text := 'www.hosxp.net';
      SubChild := Node.AddChild('USER');SubChild.Text := 'root';
      SubChild := Node.AddChild('PASSWORD');SubChild.Text := '123456';
      SubChild := Node.AddChild('DATABASE');SubChild.Text := 'hos';
      SubChild := Node.AddChild('TRACKDATE_DD');SubChild.Text := '12';
      SubChild := Node.AddChild('TRACKDATE_MM');SubChild.Text := '03';
      SubChild := Node.AddChild('TRACKDATE_YYYY');SubChild.Text := '2012';



      Node := Xml.Root.AddChild('GatewayConfig');
      SubChild := Node.AddChild('ADDRESS');SubChild.Text := 'localhost';
      SubChild := Node.AddChild('HOSTNAME');SubChild.Text := 'www.hosxp.net';
      SubChild := Node.AddChild('USER');SubChild.Text := 'root';
      SubChild := Node.AddChild('PASSWORD');SubChild.Text := '123456';
      SubChild := Node.AddChild('DATABASE');SubChild.Text := _sample_db;
      SubChild := Node.AddChild('TRACKDATE_DD');SubChild.Text := '12';
      SubChild := Node.AddChild('TRACKDATE_MM');SubChild.Text := '03';
      SubChild := Node.AddChild('TRACKDATE_YYYY');SubChild.Text := '2012';

      Xml.SaveToFile(ExtractFilePath(Application.ExeName)+_config_file);
      Xml.Free;

    end;


    // Load XML from Memo1
    Xml := TMyXml.Create;
    Xml.LoadFromFile(ExtractFilePath(Application.ExeName)+_config_file);

  //  ShowMessage(Xml.Root.Find('HOSxPConfig', 'id', 'bk103').Find('description').Text);
        _app_address      :=Xml.Root.Find('HOSxPConfig').Find('ADDRESS').Text;
        //_app_password     :=Xml.Root.Find('HOSxPConfig').Find('HOSTNAME').Text;
        _app_user     :=Xml.Root.Find('HOSxPConfig').Find('USER').Text;
        _app_password     :=Xml.Root.Find('HOSxPConfig').Find('PASSWORD').Text;
        _app_database     :=Xml.Root.Find('HOSxPConfig').Find('DATABASE').Text;
        //_app_user         :=Xml.Root.Find('HOSxPConfig').Find('TRACKDATE_DD').Text;
        //_app_user         :=Xml.Root.Find('HOSxPConfig').Find('TRACKDATE_MM').Text;
    Xml.Free;


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
(*
var rep:boolean;
xmlConn : TXMLConfig;
_app_address,_app_hostname,_app_database,_app_user,_app_password:string;
begin
  try
//    InputBox('','','HOSxpConn');
    rep:=false;
    xmlConn:=TXMLConfig.Create(ExtractFilePath(ParamStr(0))+_config_file);
    //xmlConn:=TXMLConfig.Create(_config_file);
    if (xmlConn.ReadString('HOSxPConfig','ADDRESS','')='') then
    begin
        // mssql connection
        xmlConn.WriteString('HOSxPConfig','ADDRESS','localhost');
        xmlConn.WriteString('HOSxPConfig','HOSTNAME','www.hosxp.net');
        xmlConn.WriteString('HOSxPConfig','USER','root');
        xmlConn.WriteString('HOSxPConfig','PASSWORD','123456');
        xmlConn.WriteString('HOSxPConfig','DATABASE',_sample_db);
        xmlConn.Save;
    end;

     _app_address:= xmlConn.ReadString('HOSxPConfig','ADDRESS','');
     _app_hostname:= xmlConn.ReadString('HOSxPConfig','HOSTNAME','');
     _app_database:=xmlConn.ReadString('HOSxPConfig','DATABASE','');
     _app_user:=xmlConn.ReadString('HOSxPConfig','USER','root');
     _app_password:=xmlConn.ReadString('HOSxPConfig','PASSWORD','123456');

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
      ShowMessage('Can not connect to Hos database!!'+#10#13+_app_address+'-'+_app_database+'-'+_app_user+'-'+_app_password);
    end;
  end;

  result:=rep;

end;

*)

procedure HOSxP_gwExecuteSQL(SQL: string);
var
  MyQuery: TMyQuery;
  conn : TMyConnection;
begin

  Conn := TMyConnection.Create(nil);
  initMyConnection(conn);

  MyQuery := TMyQuery.Create(nil);
  try

    MyQuery.Connection := Conn;

    MyQuery.SQL.Text := stringreplace(SQL, '"', '''', [rfreplaceall]);
    MyQuery.execute;
  finally
    MyQuery.Free;
    conn.Free;
  end;



end;





function HOSxP_gwUpdateDelta(Delta: OleVariant; SQLText: string): Integer;
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
  Conn.Database:='dba_19022013';
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



    lQuery.SQL.Text := SQLText;
    lDSP.DataSet := lQuery;
    lDSP.resolvetodataset := false;
    lDSP.updatemode := upWherekeyonly;
    //InputBox('','',lQuery.SQL.Text);

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



function HOSxP_gwUpdateDeltaA(Conn:TMyConnection;lQuery: TMyQuery;lDSP: TDataSetProvider;Delta: OleVariant; SQLText: string): Integer;
var
  lError: Integer;
  lQue: Integer;

  DeadLockDetected: boolean;

begin

  //Conn := TMyConnection.Create(nil);
  {
  conn.Username :='root';
  conn.Password :='123456';
  conn.Server :='127.0.0.1';
  Conn.Port:=3306;
  Conn.Database:='dba_19022013';
  conn.Connected:=true;
  }
  initMyConnection(conn);

 // lQuery := TMyQuery.Create(nil);

  lQuery.paramcheck := false;
  lQuery.Connection := conn;

  lDSP := TDataSetProvider.Create(nil);

  try

    SQLText := stringreplace(stringreplace(SQLText, '"', '''', [rfreplaceall]),
      '^^', '"', [rfreplaceall]);



    lQuery.SQL.Text := SQLText;
    lDSP.DataSet := lQuery;
    lDSP.resolvetodataset := false;
    lDSP.updatemode := upWherekeyonly;
    //InputBox('','',lQuery.SQL.Text);

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
    //lDSP.Free;
    //lQuery.Free;Conn//conn.Free;
  end;
  Result := lError;

end;

function HOSxP_gwGetDataSet(const SQL: string): Variant;stdcall;
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

//  repeat
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
        Conn.Database:='dba_19022013';
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
//  until not DeadLockDetected;
  if errmsg <> '' then
    raise exception.Create(errmsg);
end;


function HOSxP_gwGetDataSetA(Conn:TMyConnection;lQuery: TMyQuery;lDSP: TDataSetProvider;const SQL: string): Variant;stdcall;
var
  lError: Integer;
  lQue: Integer;

  CanExecute: boolean;
  recsout: Integer;
  DeadLockDetected: boolean;
  errmsg: string;
begin

//  repeat
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




        //Conn := TMyConnection.Create(nil);
        {
        conn.Username :='root';
        conn.Password :='123456';
        conn.Server :='127.0.0.1';
        Conn.Port:=3306;
        Conn.Database:='dba_19022013';
        }
        //initMyConnection(conn);


        //lDSP := TDataSetProvider.Create(nil);

        try

          //lQuery := TMyQuery.Create(nil);

          lQuery.Connection := conn;


         lQuery.SQL.Text := stringreplace(SQL, '"', '''', [rfreplaceall]);


          lQuery.paramcheck := false;
          lDSP.DataSet := lQuery;

          if CanExecute then
            lQuery.execute;

          if not CanExecute then

            Result := lDSP.GetRecords(-1, recsout, MetaDataOption);

        finally

         // lDSP.Free;

          //lQuery.Free;
         // Conn.Free;

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
//  until not DeadLockDetected;
  if errmsg <> '' then
    raise exception.Create(errmsg);
end;



function HOSxP_gwGetSerialNumber(sn: string): Integer; stdcall;

var
  hos3: TMyQuery;
  cancon: boolean;
  errmsg: string;
  conn:TMyConnection;
begin

  hos3 := TMyQuery.Create(nil);

  Conn := TMyConnection.Create(nil);
  initMyConnection(conn);

  hos3.Connection := conn;
  // hos3.requestlive := true;
  // hos3.paramcheck := false;

  hos3.close;
  hos3.SQL.Text := 'select get_serialnumber(''' + sn + ''') as cc ';

  errmsg := '';
  cancon := false;
  hos3.close;
  hos3.open;

  if not hos3.active then
    raise exception.Create(errmsg);

  Result := hos3.fieldbyname('cc').asinteger;
  hos3.close;

  hos3.Free;

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

function HOSxP_gwVersionInfo():integer;
begin
  result := 5602001;
end;




exports
  HOSxP_gwGetDataSet,HOSxP_gwGetDataSetA,HOSxP_gwUpdateDelta,HOSxP_gwUpdateDeltaA,HOSxP_gwVersionInfo,HOSxP_gwGetSerialNumber,HOSxP_gwExecuteSQL;

begin
CoInitialize(nil);
end.

