program ConsultaViaCEP;

uses
  Vcl.Forms,
  uConsViaCep in 'uConsViaCep.pas' {frmConsViaCEP},
  Dados in 'Core\DataModules\Dados.pas' {dmDados: TDataModule},
  uSplash in 'Core\FormDefault\uSplash.pas' {frmSplash};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmConsViaCEP, frmConsViaCEP);
  Application.CreateForm(TdmDados, dmDados);
  Application.CreateForm(TfrmSplash, frmSplash);
  frmSplash := TfrmSplash.Create(Application);
  frmSplash.Show;
	frmSplash.Update;
	Application.Initialize;
	if frmSplash.LerConfiguracoes then
	begin
		frmSplash.Hide;
		frmSplash.Free;
		Application.CreateForm(TfrmConsViaCEP, frmConsViaCEP);
		Application.Run;
	end
	else
 begin
		frmSplash.Hide;
		frmSplash.Free;
    dmDados.Free;
		Application.Terminate;
 end;
  Application.Run;
end.
