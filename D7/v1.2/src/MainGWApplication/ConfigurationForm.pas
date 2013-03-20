unit ConfigurationForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls,  DB, DBAccess, MyAccess;

type
  TformConfiguration = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    MyConnectionTest: TMyConnection;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    btnTestHosConnection: TButton;
    dtHosTrackDate: TDateTimePicker;
    edHosDBServer: TEdit;
    edHosDBName: TEdit;
    edHosUserName: TEdit;
    edHosPassword: TEdit;
    TabSheet2: TTabSheet;
    btnTestGwConnection: TButton;
    dtGwTrackDate: TDateTimePicker;
    edgwDBServer: TEdit;
    edgwDBName: TEdit;
    edgwUserName: TEdit;
    edgwPassword: TEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnTestHosConnectionClick(Sender: TObject);
    procedure btnTestGwConnectionClick(Sender: TObject);
  private
    { Private declarations }
    procedure SaveMyGwConnection();
    procedure SaveMyExtConnection();
    procedure TestConnection(_server,_user,_password,_database:string);
  public
    { Public declarations }
  end;

var
  formConfiguration: TformConfiguration;

implementation

uses uCiaXml, HOSxP_gwLIB;



{$R *.dfm}



procedure TformConfiguration.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TformConfiguration.btnOKClick(Sender: TObject);
var
xmlConn : TXMLConfig;
_app_address,_app_hostname,_app_database,_app_user,_app_password:string;
begin
    xmlConn:=TXMLConfig.Create(ExtractFilePath(Application.ExeName)+_config_file);

    xmlConn.WriteString('HOSxPConfig','ADDRESS',edHosDBServer.Text);
    xmlConn.WriteString('HOSxPConfig','HOSTNAME','www.hosxp.net');
    xmlConn.WriteString('HOSxPConfig','USER',edHosUserName.Text);
    xmlConn.WriteString('HOSxPConfig','PASSWORD',edHosPassword.Text);
    xmlConn.WriteString('HOSxPConfig','DATABASE',edHosDBName.Text);
    xmlConn.WriteString('HOSxPConfig','TRACKDATE_DD',FormatDateTime('dd',dtHosTrackDate.Date));
    xmlConn.WriteString('HOSxPConfig','TRACKDATE_MM',FormatDateTime('MM',dtHosTrackDate.Date));
    xmlConn.WriteString('HOSxPConfig','TRACKDATE_YYYY',FormatDateTime('yyyy',dtHosTrackDate.Date));

    //
    xmlConn.WriteString('ExtConfig','ADDRESS',edgwDBServer.Text);
    xmlConn.WriteString('ExtConfig','HOSTNAME','www.hosxp.net');
    xmlConn.WriteString('ExtConfig','USER',edgwUserName.Text);
    xmlConn.WriteString('ExtConfig','PASSWORD',edgwPassword.Text);
    xmlConn.WriteString('ExtConfig','DATABASE',edgwDBName.Text);
    xmlConn.WriteString('ExtConfig','TRACKDATE_DD',FormatDateTime('dd',dtGwTrackDate.Date));
    xmlConn.WriteString('ExtConfig','TRACKDATE_MM',FormatDateTime('MM',dtGwTrackDate.Date));
    xmlConn.WriteString('ExtConfig','TRACKDATE_YYYY',FormatDateTime('yyyy',dtGwTrackDate.Date));
    xmlConn.Save;

  ShowMessage('Save Configuration Success.');
  Close;
end;

procedure TformConfiguration.SaveMyExtConnection;
var rep:boolean;
xmlConn : TXMLConfig;
_app_address,_app_hostname,_app_database,_app_user,_app_password:string;
begin
  try
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

     edgwDBServer.Text:=_app_address;
     edgwDBName.Text:=_app_database;
     edgwUserName.Text := _app_user;
     edgwPassword.Text := _app_password;


  except
    on err:Exception do
    begin
      rep:=false;
      MessageDlg(err.Message,mtError,[mbOK],0);
      ShowMessage(_app_address+'-'+_app_database+'-'+_app_user+'-'+_app_password);

    end;
  end;


end;

procedure TformConfiguration.SaveMyGwConnection;
var rep:boolean;
xmlConn : TXMLConfig;
_app_address,_app_hostname,_app_database,_app_user,_app_password:string;
begin
  try
    rep:=false;
    xmlConn:=TXMLConfig.Create(ExtractFilePath(Application.ExeName)+_config_file);
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

     edHosDBServer.Text:=_app_address;
     edHosDBName.Text:=_app_database;
     edHosUserName.Text := _app_user;
     edHosPassword.Text := _app_password;


  except
    on err:Exception do
    begin
      rep:=false;
      MessageDlg(err.Message,mtError,[mbOK],0);
      ShowMessage(_app_address+'-'+_app_database+'-'+_app_user+'-'+_app_password);

    end;
  end;


end;


procedure TformConfiguration.FormShow(Sender: TObject);
begin
    SaveMyGwConnection;
    SaveMyExtConnection;
end;

procedure TformConfiguration.TestConnection(_server, _user, _password,
  _database: string);
begin
     with MyConnectionTest do
     begin
      MyConnectionTest.Connected:=false;
      MyConnectionTest.Database:=_database;
      MyConnectionTest.Server:= _server;
      MyConnectionTest.Username:=_user;
      MyConnectionTest.Password:=_password;

      MyConnectionTest.Options.Charset:='tis620';
      try
        MyConnectionTest.Connected:=true;
        Application.MessageBox(pchar('Connection Success.'),pchar('Information'),MB_OK or MB_ICONINFORMATION);
      except
        on ee :Exception do
         Application.MessageBox(pchar(ee.Message),pchar('Warning'),MB_OK or MB_ICONWARNING);
      end;

     end;
end;

procedure TformConfiguration.btnTestHosConnectionClick(Sender: TObject);
begin
  TestConnection(edHosDBServer.Text,edHosUserName.Text,edHosPassword.Text,edHosDBName.Text);
end;

procedure TformConfiguration.btnTestGwConnectionClick(Sender: TObject);
begin
  TestConnection(edgwDBServer.Text,edgwUserName.Text,edgwPassword.Text,edgwDBName.Text);
end;

end.