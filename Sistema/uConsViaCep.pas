unit uConsViaCep;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,   Dados,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uViaCEP, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinTheBezier,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, Vcl.Mask, Vcl.DBCtrls, cxMaskEdit,
  cxSpinEdit, cxDBEdit, cxTextEdit;

type
  TfrmConsViaCEP = class(TForm)
    ViaCEP: TViaCEP;
    memCEPResult: TFDMemTable;
    DataSource: TDataSource;
    memCEPResultCEP: TStringField;
    memCEPResultLOGRADOURO: TStringField;
    memCEPResultCOMPLEMENTO: TStringField;
    memCEPResultBAIRRO: TStringField;
    memCEPResultLOCALIDADE: TStringField;
    memCEPResultUF: TStringField;
    memCEPResultestado: TStringField;
    memCEPResultregiao: TStringField;
    memCEPResultibge: TIntegerField;
    memCEPResultddd: TIntegerField;
    pnlBuscaPorCEP: TPanel;
    pnlGrid: TPanel;
    edtCEP: TLabeledEdit;
    btnBuscaCEPXML: TButton;
    edtLogradouro: TLabeledEdit;
    edtBairro: TLabeledEdit;
    edtCidade: TLabeledEdit;
    edtEstado: TLabeledEdit;
    edtUF: TLabeledEdit;
    DBGrid1: TDBGrid;
    btnBuscaCEPJSON: TButton;
    procedure btnBuscaCEPXMLClick(Sender: TObject);
    procedure edtCEPKeyPress(Sender: TObject; var Key: Char);
    procedure edtCEPExit(Sender: TObject);
    procedure btnBuscaCEPJSONClick(Sender: TObject);
  private
    { Private declarations }
    procedure AtivarComponentes(Ativar: Boolean);
    procedure BuscaCep(TipoBusca: TViaCEPRetorno);
  public
    { Public declarations }
  end;

var
  frmConsViaCEP: TfrmConsViaCEP;

implementation

{$R *.dfm}

procedure TfrmConsViaCEP.AtivarComponentes(Ativar: Boolean);
var
  I: Integer;
begin
  for I := 0 to self.ComponentCount - 1 do
  begin
    if (self.Components[I] is TDBGrid) then
    begin
      TControl(self.Components[I]).Visible := Ativar;
    end;
  end;
end;

procedure TfrmConsViaCEP.btnBuscaCEPJSONClick(Sender: TObject);
begin
  BuscaCep(tpJSON);
end;

procedure TfrmConsViaCEP.btnBuscaCEPXMLClick(Sender: TObject);
begin
  BuscaCep(tpXML);
end;

procedure TfrmConsViaCEP.BuscaCep(TipoBusca: TViaCEPRetorno);
var
  I: Integer;
begin
  AtivarComponentes(False);
  memCEPResult.Active := False;

  ViaCEP.Format := TipoBusca;
  ViaCEP.DBTabelaEndereco := 'ENDERECO';
  ViaCEP.DBConnection := dmDados.FDConnection;
  ViaCEP.ConsultarEndereco(edtCEP.Text, edtLogradouro.Text, edtCidade.Text, edtUF.Text);

  if ViaCEP.ListaEndereco.Count <= 0 then
  begin
    MessageDlg('CEP e/ou Endereço não encontrado!',mtInformation,[mbOK],0);
    Exit;
  end;

  for I := 0 to ViaCEP.ListaEndereco.Count - 1 do
  begin
    if not memCEPResult.Active then
      memCEPResult.Active := True;

    memCEPResult.Insert;
    memCEPResultCEP.AsString := ViaCEP.ListaEndereco[I].CEP;
    memCEPResultLOGRADOURO.AsString := ViaCEP.ListaEndereco[I].Logradouro;
    memCEPResultCOMPLEMENTO.AsString := ViaCEP.ListaEndereco[I].Complemento;
    memCEPResultBAIRRO.AsString := ViaCEP.ListaEndereco[I].Bairro;
    memCEPResultLOCALIDADE.AsString := ViaCEP.ListaEndereco[I].Localidade;
    memCEPResultUF.AsString := ViaCEP.ListaEndereco[I].UF;
    memCEPResultestado.AsString := ViaCEP.ListaEndereco[I].Estado;
    memCEPResult.Post;
  end;

  memCEPResult.First;

  edtCEP.Text       := memCEPResultCEP.AsString;
  edtLogradouro.Text:= memCEPResultLOGRADOURO.AsString;
  edtBairro.Text    := memCEPResultBAIRRO.AsString;
  edtCidade.Text    := memCEPResultLOCALIDADE.AsString;
  edtEstado.Text    := memCEPResultestado.AsString;
  edtUF.Text        := memCEPResultUF.AsString;

  if ViaCEP.ListaEndereco.Count > 1 then
    if MessageDlg('Mais de um CEP atualizado, deseja visualizar todos ?', mtConfirmation,[mbyes,mbno],0)= mrYes then
       AtivarComponentes(True);
end;

procedure TfrmConsViaCEP.edtCEPExit(Sender: TObject);
var
  CEP: string;
begin
  CEP := TEdit(Sender).Text;
  if Length(CEP) = 8 then
  begin
    TEdit(Sender).Text := Copy(CEP, 1, 5) + '-' + Copy(CEP, 6, 3);
  end
  else
  if Length(CEP) > 8 then
  begin
    ShowMessage('CEP inválido! Insira 8 dígitos.');
    TEdit(Sender).SetFocus;
  end;
end;

procedure TfrmConsViaCEP.edtCEPKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

end.
