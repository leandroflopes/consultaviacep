unit uViaCEP;

interface

uses
  System.SysUtils, System.Classes, IdHTTP, IdSSLOpenSSL, Xml.XMLDoc, Xml.XMLIntf,
  System.Net.HttpClientComponent, System.Net.HttpClient, System.JSON,
  System.IOUtils, System.Generics.Collections,FireDAC.Comp.Client, vcl.dialogs;

type
  TViaCEPRetorno = (tpXML, tpJSON);

  type
    TEndereco = class
    CEP: string;
    Logradouro: string;
    Complemento: string;
    Bairro: string;
    Localidade: string;
    UF: string;
    Estado: string;
    Regiao: string;
    IBGE: string;
    DDD: string;
    SIAFI: string;
    CODIGO: INTEGER;
  end;

  TViaCEP = class(TComponent)
  private
    FHTTP: TNetHTTPRequest;
    FSSL: TNetHTTPClient;
    FResponse:IHTTPResponse;
    FFormat: TViaCEPRetorno;
    FOnError: TNotifyEvent;
    FListaEndereco: TObjectList<TEndereco>;
    FConnection: TFDConnection;
    FQuery: TFDQuery;
    FTabelaEndereco: String;
    procedure HandleError(ErrMsg: string);
    procedure ConsultarPorCEP(CEP, Response: string);
    procedure ConsultarPorEndereco(Logradouro, Cidade, UF, Response: string);
    property Query: TFDQuery read FQuery write FQuery;
    procedure BDConsultaCEP(CEP:String);
    procedure BDConsultarEndereco(Logradouro, Cidade, UF: string);
    procedure BDInsereAtualizaCEP;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ConsultarEndereco(CEP, Logradouro, Cidade, UF: string);
    property ListaEndereco : TObjectList<TEndereco> read FListaEndereco write FListaEndereco;
  published
    property Format: TViaCEPRetorno read FFormat write FFormat default tpXML;
    property OnError: TNotifyEvent read FOnError write FOnError;
    property DBConnection: TFDConnection read FConnection write FConnection;
    property DBTabelaEndereco: String read FTabelaEndereco write FTabelaEndereco;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SOFTPLAN', [TViaCEP]);
end;

procedure TViaCEP.BDConsultaCEP(CEP: String);
var
  Lista: TEndereco;
begin
  if not Assigned(DBConnection) then
    raise Exception.Create('DBConnection não pode ser vazio!');

  Query.Connection := DBConnection;
  Query.SQL.Clear;
  Query.SQL.Add(' Select * from '+DBTabelaEndereco+' where CEP = :PCEP');
  Query.Prepare;
  Query.ParamByName('PCEP').AsString := CEP;
  Query.Open;
  Query.First;

  if not Query.IsEmpty then
    if MessageDlg('Endereço já cadastrado na base de dados. Deseja Atualizar ?',
                   mtConfirmation,[mbyes,mbno],0)= 7 then
     begin
       Lista := TEndereco.Create;
       lista.Logradouro := Query.FieldByName('logradouro').AsString;
       lista.Bairro := Query.FieldByName('Bairro').AsString;
       lista.Localidade := Query.FieldByName('Localidade').AsString;
       lista.UF := Query.FieldByName('UF').AsString;
       lista.Estado := Query.FieldByName('Estado').AsString;
       lista.CEP := Query.FieldByName('CEP').AsString;
       ListaEndereco.Add(Lista);
     end;
end;

procedure TViaCEP.BDConsultarEndereco(Logradouro, Cidade, UF: string);
var
  Lista: TEndereco;
begin
  if not Assigned(DBConnection) then
    raise Exception.Create('DBConnection não pode ser vazio!');

  Query.Connection := DBConnection;
  Query.SQL.Clear;
  Query.SQL.Add(' Select * from '+DBTabelaEndereco+' where ');
  Query.SQL.Add(' Logradouro = :Logradouro and LOCALIDADE = :LOCALIDADE ');
  Query.SQL.Add(' and UF = :UF');
  Query.Prepare;
  Query.ParamByName('UF').AsString := UF;
  Query.ParamByName('Logradouro').AsString := Logradouro;
  Query.ParamByName('LOCALIDADE').AsString := Cidade;
  Query.Open;
  Query.First;

  if not Query.IsEmpty then
    if MessageDlg('Endereço já cadastrado na base de dados. Deseja Atualizar ?',
                   mtConfirmation,[mbyes,mbno],0)= 7 then
     begin
       Lista := TEndereco.Create;
       lista.Logradouro := Query.FieldByName('logradouro').AsString;
       lista.Bairro := Query.FieldByName('Bairro').AsString;
       lista.Localidade := Query.FieldByName('Localidade').AsString;
       lista.UF := Query.FieldByName('UF').AsString;
       lista.Estado := Query.FieldByName('Estado').AsString;
       lista.CEP := Query.FieldByName('CEP').AsString;
       ListaEndereco.Add(Lista);
     end;
end;

procedure TViaCEP.BDInsereAtualizaCEP;
var
  i : Integer;
begin
  if not Assigned(DBConnection) then
    raise Exception.Create('DBConnection não pode ser vazio!');

  Query.Connection := DBConnection;
  Query.SQL.Clear;
  Query.SQL.Add(' UPDATE OR INSERT INTO '+DBTabelaEndereco+' (CEP, LOGRADOURO, COMPLEMENTO, ');
  Query.SQL.Add(' BAIRRO, LOCALIDADE, UF, ESTADO) ');
  Query.SQL.Add(' VALUES (:CEP, :LOGRADOURO, :COMPLEMENTO, :BAIRRO, :LOCALIDADE, ');
  Query.SQL.Add(' :UF, :ESTADO )  MATCHING (CEP) ');
  Query.Prepare;

  for I := 0 to ListaEndereco.Count - 1 do
  begin
    Query.ParamByName('CEP').AsString := ListaEndereco[I].CEP;
    Query.ParamByName('LOGRADOURO').AsString := ListaEndereco[I].Logradouro;
    Query.ParamByName('COMPLEMENTO').AsString := ListaEndereco[I].Complemento;
    Query.ParamByName('BAIRRO').AsString := ListaEndereco[I].Bairro;
    Query.ParamByName('LOCALIDADE').AsString := ListaEndereco[I].Localidade;
    Query.ParamByName('UF').AsString := ListaEndereco[I].UF;
    Query.ParamByName('ESTADO').AsString := ListaEndereco[I].Estado;

    Query.ExecSQL;
  end;

end;

procedure TViaCEP.ConsultarEndereco(CEP, Logradouro, Cidade, UF: string);
var
  ResultResponse: string;
  URL : string;
  BuscaPorCEP : Boolean;
begin
  if (Length(UF+Cidade+Logradouro) < 4) and (CEP.IsEmpty) then
    raise Exception.Create('Endereço deve ser preenchido : CEP, UF, Cidade e Logradouro!');

  CEP := CEP.Replace('-','', [rfReplaceAll]);
  BuscaPorCEP := CEP.Trim.Length = 8;

  if not Assigned(ListaEndereco) then
    ListaEndereco := TObjectList<TEndereco>.Create(True)
  else
    ListaEndereco.Clear;

  case FFormat of
    tpXML: begin
             if BuscaPorCEP then
             begin
               BDConsultaCEP(CEP);
               URL := 'https://viacep.com.br/ws/' + CEP + '/xml/'
             end
             else
             begin
               BDConsultarEndereco(Logradouro, Cidade, UF);
               URL := 'https://viacep.com.br/ws/' + UF + '/'+ Cidade + '/' + Logradouro + '/xml/';
             end;
           end;

    tpJSON:begin
            if BuscaPorCEP then
            begin
              BDConsultaCEP(CEP);
              URL := 'https://viacep.com.br/ws/' + CEP + '/json/'
            end
            else
            begin
              BDConsultarEndereco(Logradouro, Cidade, UF);
              URL := 'https://viacep.com.br/ws/' + UF + '/'+ Cidade + '/' + Logradouro + '/json/';
            end;
          end;
  end;

  try
    FResponse := FHTTP.Get(URL);
    ResultResponse := FResponse.ContentAsString();

    if (ListaEndereco.Count > 0) or (Length(trim(ResultResponse))<80) or
        (FResponse.StatusCode = 400) then
    begin
      Exit;
    end;

  except
    on E: Exception do
      HandleError(E.Message);
  end;

  if BuscaPorCEP then
    ConsultarPorCEP(CEP, ResultResponse)
  else
    ConsultarPorEndereco(Logradouro,Cidade,UF, ResultResponse);

  BDInsereAtualizaCEP;
end;

procedure TViaCEP.ConsultarPorCEP(CEP, Response: string);
var
  JSONObj: TJSONObject;
  XMLDoc: IXMLDocument;
  Lista: TEndereco;
  I: Integer;
begin
  case FFormat of
    tpXML:
      begin
        XMLDoc := TXMLDocument.Create(nil);
        try
          XMLDoc.LoadFromXML(Response);
          XMLDoc.Active := True;

          Lista := TEndereco.Create;
          lista.Logradouro := XMLDoc.DocumentElement.ChildNodes.FindNode('logradouro').Text;
          lista.Bairro := XMLDoc.DocumentElement.ChildNodes.FindNode('bairro').Text;
          lista.Localidade := XMLDoc.DocumentElement.ChildNodes.FindNode('localidade').Text;
          lista.UF := XMLDoc.DocumentElement.ChildNodes.FindNode('uf').Text;
          lista.Estado := XMLDoc.DocumentElement.ChildNodes.FindNode('estado').Text;
          lista.CEP := XMLDoc.DocumentElement.ChildNodes.FindNode('cep').Text;
          ListaEndereco.Add(Lista);

        except
          on E: Exception do
            HandleError(E.Message);
        end;
      end;

    tpJSON:
      begin
        try
          JSONObj := TJSONObject.ParseJSONValue(Response) as TJSONObject;
          if JSONObj <> nil then
          try
            Lista := TEndereco.Create;
            lista.CEP         := JSONObj.GetValue('cep').Value;
            lista.Bairro      := JSONObj.GetValue('bairro').Value;
            lista.Localidade  := JSONObj.GetValue('localidade').Value;
            lista.UF          := JSONObj.GetValue('uf').Value;
            lista.Logradouro  := JSONObj.GetValue('logradouro').Value;
            lista.Complemento := JSONObj.GetValue('complemento').Value;
            lista.Estado      := JSONObj.GetValue('estado').Value;
            ListaEndereco.Add(Lista);
          finally
            JSONObj.Free;
          end;
        except
          on E: Exception do
            HandleError(E.Message);
        end;
      end;
  end;
end;

procedure TViaCEP.ConsultarPorEndereco(Logradouro, Cidade, UF, Response: string);
var
  Lista: TEndereco;
  JSONString: string;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  XMLDoc: IXMLDocument;
  Node, EnderecoNode,EnderecosNode: IXMLNode;
  I: Integer;
begin
  case FFormat of
    tpXML:
      begin
        XMLDoc := TXMLDocument.Create(nil);
        try
          XMLDoc.LoadFromXML(Response);
          XMLDoc.Active := True;
          Node := XMLDoc.DocumentElement;
          EnderecosNode := Node.ChildNodes['enderecos'];


          for I := 0 to EnderecosNode.ChildNodes.Count - 1 do
          begin
            EnderecoNode := EnderecosNode.ChildNodes[I];

            Lista := TEndereco.Create;
            lista.Logradouro  := EnderecoNode.ChildNodes.FindNode('logradouro').Text;
            lista.Bairro      := EnderecoNode.ChildNodes.FindNode('bairro').Text;
            lista.Localidade  := EnderecoNode.ChildNodes.FindNode('localidade').Text;
            lista.UF          := EnderecoNode.ChildNodes.FindNode('uf').Text;
            lista.Estado      := EnderecoNode.ChildNodes.FindNode('estado').Text;
            lista.CEP         := EnderecoNode.ChildNodes.FindNode('cep').Text;
            ListaEndereco.Add(Lista);

          end;
        except
          on E: Exception do
            HandleError(E.Message);
        end;
      end;

    tpJSON:
      begin
        try
          JSONString := Response;
          JSONArray := TJSONObject.ParseJSONValue(JSONString) as TJSONArray;

          if Assigned(JSONArray) then
          begin
            for I := 0 to JSONArray.Count - 1 do
            begin
              JSONObject := JSONArray.Items[I] as TJSONObject;

              Lista := TEndereco.Create;
              lista.CEP         := JSONObject.GetValue('cep').Value;
              lista.Bairro      := JSONObject.GetValue('bairro').Value;
              lista.Localidade  := JSONObject.GetValue('localidade').Value;
              lista.UF          := JSONObject.GetValue('uf').Value;
              lista.Logradouro  := JSONObject.GetValue('logradouro').Value;
              lista.Complemento := JSONObject.GetValue('complemento').Value;
              lista.Estado      := JSONObject.GetValue('estado').Value;
              ListaEndereco.Add(Lista);
            end;
          end;
        finally
            FreeAndNil(JSONArray);
        end;
      end;
  end;
end;

constructor TViaCEP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Query := TFDQuery.Create(AOwner);
  FHTTP := TNetHTTPRequest.Create(nil);
  FSSL := TNetHTTPClient.Create(nil);
  FHTTP.Client := FSSL;
  FFormat := tpXML;
end;

destructor TViaCEP.Destroy;
begin
  if Assigned(FSSL) then
    FreeAndNil(FSSL);

  if Assigned(FHTTP) then
    FreeAndNil(FHTTP);

  if Assigned(ListaEndereco) then
    ListaEndereco.Free;

  inherited Destroy;
end;

procedure TViaCEP.HandleError(ErrMsg: string);
begin
  if Assigned(FOnError) then
    FOnError(Self);
end;

end.
