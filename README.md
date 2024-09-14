# ViaCEP - Componente de consulta CEP XML/JSON - Delphi.
![Delphi Supported Versions](https://img.shields.io/badge/Delphi%20Supported%20Versions-XE%20and%20ever-blue.svg)
![Platforms](https://img.shields.io/badge/Platforms-Win32%20and%20Win64-red.svg)
![Compatibility](https://img.shields.io/badge/Compatibility-VCL,%20Firemonkey%20DataSnap%20and%20uniGUI-brightgreen.svg)

## Pré-requisitos
* O Componente tem conexão com o banco de dados atraves do FireDac, setado e configurado para FireBird 2.5.
 
## Instalação utilizando o Boss
* boss install github.com/leandroflopes/consultaviacep

## Instalação manual
* Obtenha o componente munido do projeto, abra o ...Componentes\ViaCep\ViaCep.dpk build e na sequencia instale, após instalar caso necessario, nas opções do projeto, deverá adicionar ..Delphi Compiler/Search Patch o caminho do componente ...Componentes\ViaCep

## Começando
* O componente vai ser instalado em uma nova paleta chamada SOFTPLAN/TViaCep. Para utilizar basta inserir ele do dfm/vcl.
  
### Como configurar e utilizar
* Nosso componete precisa de uma Conexão com BD; no exemplo foi utilizado o FDConnection e FireBird 2.5.
* Para rodar o projeto será necessario que esteja instalado o Firebird 2.5, junto ao projeto demo, temos o banco de dados e o arquivo config.ini que esta junto ao aplicativo em ...Sistema\Win32\Debug.
* Estando Config.ini configurado e Firebird instalado basta executar o aplicativo teste.*

## Exemplo prático de como configurar e chamar nossa função

## Código Delphi
```delphi
procedure BuscaCep(TipoBusca: TViaCEPRetorno);
var
  I: Integer;
begin
  ViaCEP.Format := TipoBusca; { Tipo de Busca se refere a tpXML ou tpJSON }
  ViaCEP.DBTabelaEndereco := 'ENDERECO'; { Tabela que vai procurar o CEP ou Endereço }
  ViaCEP.DBConnection := dmDados.FDConnection; { Connction já configrado }
  ViaCEP.ConsultarEndereco(edtCEP.Text, edtLogradouro.Text, edtCidade.Text, edtUF.Text); { Função de Busca }
 
  for I := 0 to ViaCEP.ListaEndereco.Count - 1 do   { Exemplo de como obter os valores encontrados na busca e Gravando em um MemTable }
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
End;

```

ViaCEP - Webservice CEP e IBGE gratuito: [**Acessar Site**](https://viacep.com.br/)
