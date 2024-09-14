object frmConsViaCEP: TfrmConsViaCEP
  Left = 0
  Top = 0
  Caption = 'Consulta CEP'
  ClientHeight = 319
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBuscaPorCEP: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 622
    Height = 167
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlPrincipal'
    ShowCaption = False
    TabOrder = 0
    ExplicitLeft = 48
    ExplicitTop = 37
    ExplicitWidth = 625
    ExplicitHeight = 276
    object edtCEP: TLabeledEdit
      Left = 15
      Top = 24
      Width = 121
      Height = 21
      EditLabel.Width = 19
      EditLabel.Height = 13
      EditLabel.Caption = 'CEP'
      TabOrder = 0
      OnExit = edtCEPExit
      OnKeyPress = edtCEPKeyPress
    end
    object btnBuscaCEPXML: TButton
      Left = 15
      Top = 82
      Width = 121
      Height = 25
      Caption = 'Busca CEP XML'
      TabOrder = 7
      OnClick = btnBuscaCEPXMLClick
    end
    object edtLogradouro: TLabeledEdit
      Left = 140
      Top = 24
      Width = 400
      Height = 21
      EditLabel.Width = 55
      EditLabel.Height = 13
      EditLabel.Caption = 'Logradouro'
      TabOrder = 1
    end
    object edtBairro: TLabeledEdit
      Left = 140
      Top = 61
      Width = 400
      Height = 21
      EditLabel.Width = 28
      EditLabel.Height = 13
      EditLabel.Caption = 'Bairro'
      TabOrder = 2
    end
    object edtCidade: TLabeledEdit
      Left = 140
      Top = 99
      Width = 400
      Height = 21
      EditLabel.Width = 33
      EditLabel.Height = 13
      EditLabel.Caption = 'Cidade'
      TabOrder = 3
    end
    object edtEstado: TLabeledEdit
      Left = 140
      Top = 136
      Width = 340
      Height = 21
      EditLabel.Width = 33
      EditLabel.Height = 13
      EditLabel.Caption = 'Estado'
      TabOrder = 4
    end
    object edtUF: TLabeledEdit
      Left = 486
      Top = 136
      Width = 54
      Height = 21
      EditLabel.Width = 13
      EditLabel.Height = 13
      EditLabel.Caption = 'UF'
      TabOrder = 5
    end
    object btnBuscaCEPJSON: TButton
      Left = 15
      Top = 51
      Width = 121
      Height = 25
      Caption = 'Busca CEP JSON'
      TabOrder = 6
      OnClick = btnBuscaCEPJSONClick
    end
  end
  object pnlGrid: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 176
    Width = 622
    Height = 140
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'pnlGrid'
    ShowCaption = False
    TabOrder = 1
    ExplicitTop = 256
    object DBGrid1: TDBGrid
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 616
      Height = 134
      Align = alClient
      DataSource = DataSource
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Visible = False
    end
  end
  object ViaCEP: TViaCEP
    Format = tpJSON
    Left = 496
    Top = 320
  end
  object memCEPResult: TFDMemTable
    Active = True
    FieldDefs = <
      item
        Name = 'CEP'
        DataType = ftString
        Size = 12
      end
      item
        Name = 'LOGRADOURO'
        DataType = ftString
        Size = 25
      end
      item
        Name = 'BAIRRO'
        DataType = ftString
        Size = 25
      end
      item
        Name = 'LOCALIDADE'
        DataType = ftString
        Size = 25
      end
      item
        Name = 'COMPLEMENTO'
        DataType = ftString
        Size = 25
      end
      item
        Name = 'estado'
        DataType = ftString
        Size = 25
      end
      item
        Name = 'UF'
        DataType = ftString
        Size = 5
      end
      item
        Name = 'regiao'
        DataType = ftString
        Size = 50
      end
      item
        Name = 'ibge'
        DataType = ftInteger
      end
      item
        Name = 'ddd'
        DataType = ftInteger
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 672
    Top = 240
    object memCEPResultCEP: TStringField
      DisplayWidth = 12
      FieldName = 'CEP'
      Size = 12
    end
    object memCEPResultLOGRADOURO: TStringField
      DisplayLabel = 'Logradouro'
      FieldName = 'LOGRADOURO'
      Size = 25
    end
    object memCEPResultBAIRRO: TStringField
      DisplayLabel = 'Bairro'
      FieldName = 'BAIRRO'
      Size = 25
    end
    object memCEPResultLOCALIDADE: TStringField
      DisplayLabel = 'Localidade'
      FieldName = 'LOCALIDADE'
      Size = 25
    end
    object memCEPResultCOMPLEMENTO: TStringField
      DisplayLabel = 'Complemento'
      FieldName = 'COMPLEMENTO'
      Size = 25
    end
    object memCEPResultestado: TStringField
      DisplayLabel = 'Estado'
      FieldName = 'estado'
      Size = 25
    end
    object memCEPResultUF: TStringField
      FieldName = 'UF'
      Size = 5
    end
    object memCEPResultregiao: TStringField
      DisplayLabel = 'Regi'#227'o'
      FieldName = 'regiao'
      Size = 50
    end
    object memCEPResultibge: TIntegerField
      DisplayLabel = 'IBGE'
      FieldName = 'ibge'
    end
    object memCEPResultddd: TIntegerField
      DisplayLabel = 'DDD'
      FieldName = 'ddd'
    end
  end
  object DataSource: TDataSource
    DataSet = memCEPResult
    Left = 672
    Top = 296
  end
end
