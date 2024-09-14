unit Dados;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, System.IniFiles, FireDAC.Phys.FBDef,
  FireDAC.Comp.UI, FireDAC.Phys.IBBase, FireDAC.Phys.FB, vcl.forms,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet,  System.Generics.Collections,Vcl.Dialogs;

type
  TdmDados = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    Transaction: TFDTransaction;
    qryConsultaCEP: TFDQuery;
  private
    { Private declarations }
  public
    { Public declarations }
		function ConectarBD: Boolean;
    procedure ConfigureBD;
  end;

var
  dmDados: TdmDados;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmDados }

function TdmDados.ConectarBD: Boolean;
begin
  ConfigureBD;

	FDConnection.Connected := False;
	try
		FDConnection.Connected := True;
		Result := True;
	except
		on E: Exception do
		begin
			 MessageDlg('Não foi possível conectar ao banco de dados!'#13 + 'Erro: '
					+ E.Message, mtWarning,[mbOk],0);
			Result := False;
		end;
	end;
end;

procedure TdmDados.ConfigureBD;
var
  IniFile: TIniFile;
  ConnectionDef: TFDConnectionDefParams;
begin

  IniFile := TIniFile.Create(ExtractFileDir(Application.ExeName)+'\config.ini');
  try
    FDConnection.Params.DriverID := IniFile.ReadString('Database', 'DriverID', 'FB');
    FDConnection.Params.Database := IniFile.ReadString('Database', 'Database', '');
    FDConnection.Params.UserName := IniFile.ReadString('Database', 'User_Name', '');
    FDConnection.Params.Password := IniFile.ReadString('Database', 'Password', '');
    FDConnection.Params.Add('Server=' + IniFile.ReadString('Database', 'Server', 'localhost'));
    FDConnection.Params.Add('Port=' + IniFile.ReadString('Database', 'Port', '3050'));
  finally
    IniFile.Free;
  end;
end;


end.
