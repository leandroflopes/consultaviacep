unit uSplash;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, IniFiles,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, dxGDIPlusClasses,
	Vcl.ExtCtrls, REST.Types, Dados;

type
	TfrmSplash = class(TForm)
		lblDescricao: TLabel;
	private
		{ Private declarations }
	public
		{ Public declarations }
		procedure Descricao(AValue: String);
		function LerConfiguracoes: Boolean;

	end;

var
	frmSplash: TfrmSplash;

implementation

{$R *.dfm}

procedure TfrmSplash.Descricao(AValue: String);
begin
	Application.ProcessMessages;
	lblDescricao.Caption := AValue;
	Sleep(300);
	Application.ProcessMessages;
end;

function TfrmSplash.LerConfiguracoes: Boolean;
{var
	LocalArquivoINI: String;}
begin
	try
		Result := True;
		Application.ProcessMessages;
		Descricao('Conectando no Banco de Dados.');

		if not dmDados.ConectarBD then
		begin
			Result := False;
			Exit;
		end;

		Sleep(300);
	except
		on E: Exception do
		begin
			MessageDlg(E.Message, mtError, [mbOK], 0);
			Close;
			Result := False;
		end;
	end;

end;

end.
