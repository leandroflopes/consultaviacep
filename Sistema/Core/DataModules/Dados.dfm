object dmDados: TdmDados
  OldCreateOrder = False
  Height = 325
  Width = 448
  object FDConnection: TFDConnection
    Left = 192
    Top = 88
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 136
    Top = 32
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrAppWait
    Left = 264
    Top = 32
  end
  object Transaction: TFDTransaction
    Connection = FDConnection
    Left = 264
    Top = 88
  end
  object qryConsultaCEP: TFDQuery
    Connection = FDConnection
    Left = 344
    Top = 192
  end
end
