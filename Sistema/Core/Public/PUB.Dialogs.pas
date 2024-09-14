unit PUB.Dialogs;

interface

uses
  Classes,
  Forms,
  Dialogs,
  StdCtrls,
  Windows,
  ExtCtrls,
  Math,
  StrUtils,
  Controls,
  SysUtils,
  ComCtrls,
  Graphics,
  Messages,
  UITypes,
  AppEvnts,
  Types;

type
  TMsgDlgType    = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom);
  TMsgDlgBtn     = (mbYes, mbNo, mbOK, mbCancel, mbAbort, mbRetry, mbIgnore, mbAll, mbNoToAll, mbYesToAll, mbHelp, mbClose);
  TMsgDlgButtons = set of TMsgDlgBtn;

procedure MessageBoxError(const Msg: string);
function  MessageBoxYesNo(const Msg: string): Integer;
function  MessageBoxYesNoCancel(const Msg: string): Integer;
procedure MessageBoxInformation(const Msg: string);
function  MessageBox(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TMsgDlgBtn): Integer;

procedure WaitShowMessage(const Msg: string = 'Processando solicitação ...');
procedure WaitShowProgress(const Msg: string = 'Processando solicitação ...'; ExecProc: TProc = nil); overload;
procedure WaitShowProgress(const Msg: string = 'Processando solicitação ...'; ExecFunc: TFunc<Boolean> = nil); overload;
procedure WaitCloseMessage;

implementation

resourcestring
  SMsgDlgWarning = 'Atenção';
  SMsgDlgError = 'Erro';
  SMsgDlgInformation = 'Informação';
  SMsgDlgConfirm = 'Confirme';
  SMsgDlgYes = '&Sim';
  SMsgDlgNo = '&Não';
  SMsgDlgOK = 'OK';
  SMsgDlgCancel = 'Cancelar';
  SMsgDlgAbort = '&Abortar';
  SMsgDlgRetry = '&Repetir';
  SMsgDlgIgnore = '&Ignorar';
  SMsgDlgAll = '&Todos';
  SMsgDlgNoToAll = 'Nã&o à todos';
  SMsgDlgYesToAll = 'Si&m à todos';
  SMsgDlgHelp = 'Aj&uda';
  SMsgDlgClose = '&Fechar';
  SMsgDlgCopyToClipBrd = 'Copiar mensagem';
  SHintMsgDlgCopyToClipBrd = 'Copia a mensagem para a área de transferência';

var
  Captions: array [TMsgDlgType] of Pointer = (
    @SMsgDlgWarning,
    @SMsgDlgError,
    @SMsgDlgInformation,
    @SMsgDlgConfirm,
    nil
  );

  IconIDs: array [TMsgDlgType] of PChar = (
    IDI_EXCLAMATION,
    IDI_HAND,
    IDI_ASTERISK,
    IDI_QUESTION,
    nil
  );

  ButtonCaptions: array [TMsgDlgBtn] of Pointer = (
    @SMsgDlgYes,
    @SMsgDlgNo,
    @SMsgDlgOK,
    @SMsgDlgCancel,
    @SMsgDlgAbort,
    @SMsgDlgRetry,
    @SMsgDlgIgnore,
    @SMsgDlgAll,
    @SMsgDlgNoToAll,
    @SMsgDlgYesToAll,
    @SMsgDlgHelp,
    @SMsgDlgClose
  );

  ButtonNames: array [TMsgDlgBtn] of string = (
    'Yes',
    'No',
    'OK',
    'Cancel',
    'Abort',
    'Retry',
    'Ignore',
    'All',
    'NoToAll',
    'YesToAll',
    'Help',
    'Close'
  );

  ModalResults: array [TMsgDlgBtn] of Integer = (
    mrYes,
    mrNo,
    mrOk,
    mrCancel,
    mrAbort,
    mrRetry,
    mrIgnore,
    mrAll,
    mrNoToAll,
    mrYesToAll,
    0,
    mrClose
  );

  ButtonWidths: array [TMsgDlgBtn] of Integer; // inicializa com zero

type
  TMessageForm = class(TForm)
  private
    RichEditMessage: TRichEdit;
    procedure HelpButtonClick(Sender: TObject);
  protected
    procedure CustomKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CustomEnter(Sender: TObject);
    procedure CutomLabelClick(Sender: TObject);
    procedure CustomWriteTextToClipBoard;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

type
  TWaitForm = class(TForm)
  private
    PanelContainer: TPanel;
    LabelMessage  : TLabel;
    AppEvents     : TApplicationEvents;
  protected
    procedure CustomCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CustomAppEventsModalBegin(Sender: TObject);
  end;

  { TMessageForm }

var
  FExeVErsion: string;

constructor TMessageForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  Font.Assign(Screen.MessageFont);
end;

procedure TMessageForm.CustomEnter(Sender: TObject);
begin
  if Sender = RichEditMessage then
    Perform($0028, 0, 0);
end;

procedure TMessageForm.CustomKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = Word('C')) then
  begin
    MessageBeep(0);
    CustomWriteTextToClipBoard;
  end;
end;

procedure TMessageForm.CustomWriteTextToClipBoard;
var
  FData   : THandle;
  FDataPtr: Pointer;
  FText   : string;
begin
  if OpenClipBoard(0) then
  begin
    if FExeVErsion.Trim.IsEmpty then
      FText := Caption + sLineBreak + Trim(RichEditMessage.Text)
    else
      FText := Caption + ' - ' + FExeVErsion + sLineBreak + Trim(RichEditMessage.Text);
    try
      FData := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, ByteLength(FText) + SizeOf(WideChar));
      try
        FDataPtr := GlobalLock(FData);
        try
          Move(PWChar(FText)^, FDataPtr^, ByteLength(FText) + SizeOf(WideChar));
          EmptyClipBoard;
          SetClipboardData(CF_UNICODETEXT, FData);
        finally
          GlobalUnlock(FData);
        end;
      except
        GlobalFree(FData);
        raise;
      end;
    finally
      CloseClipBoard;
    end;
  end
  else
    raise Exception.Create('Não foi possível acessar a área de transferência.');
end;

procedure TMessageForm.CutomLabelClick(Sender: TObject);
begin
  MessageBeep(0);
  CustomWriteTextToClipBoard;
end;

procedure TMessageForm.HelpButtonClick(Sender: TObject);
begin
  if HelpContext <> 0 then
    Application.HelpContext(HelpContext);
end;

function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  I     : Integer;
  Buffer: array [0 .. 51] of Char;
begin
  for I := 0 to 25 do
    Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do
    Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

function TaskBarBounds: TRect;
begin
  GetWindowRect(FindWindow('Shell_TrayWnd', nil), Result);
end;

function TaskBarPosition: TAlign;
var
  TaskBar   : TRect;
  ScrW, ScrH: Integer;
begin
  ScrW := Screen.Width;
  ScrH := Screen.Height;
  TaskBar := TaskBarBounds;
  if (TaskBar.Top > ScrH div 2) and (TaskBar.Right >= ScrW) then
    Result := alBottom
  else
    if (TaskBar.Top < ScrH div 2) and (TaskBar.Bottom <= ScrW div 2) then
    Result := alTop
  else
    if (TaskBar.Left < ScrW div 2) and (TaskBar.Top <= 0) then
    Result := alLeft
  else
    Result := alRight;
end;

function TaskBarWidth: Integer;
begin
  with TaskBarBounds do
    Result := Right - Left;
end;

function TaskBarHeight: Integer;
begin
  with TaskBarBounds do
    Result := Bottom - Top;
end;

function GetExeVersion: string;
type
  pFFI = ^VS_FIXEDFILEINFO;
var
  F               : pFFI;
  dwHandle, dwLen : DWORD;
  szInfo          : LongInt;
  pchData, pchFile: PChar;
  ptrBuff         : Pointer;
  strFile         : string;
begin
  strFile := Application.ExeName;
  pchFile := StrAlloc(Length(strFile) + 1);
  StrPcopy(pchFile, strFile);
  szInfo := GetFileVersionInfoSize(pchFile, dwHandle);
  Result := '';
  if szInfo > 0 then
  begin
    pchData := StrAlloc(szInfo + 1);
    if GetFileVersionInfo(pchFile, dwHandle, szInfo, pchData) then
    begin
      VerQueryValue(pchData, '\', ptrBuff, dwLen);
      F := pFFI(ptrBuff);
      Result := Format('v%d.%d.%d (%.3d) %s', [
        HiWord(F^.dwFileVersionMs),
        LoWord(F^.dwFileVersionMs),
        HiWord(F^.dwFileVersionLs),
        LoWord(F^.dwFileVersionLs),
{$IFDEF DEBUG}'Debug'{$ELSE}''{$ENDIF}]).Trim;
    end;
    StrDispose(pchData);
  end;
  StrDispose(pchFile);
end;

function CreateMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TMsgDlgBtn): TForm;
const
  mcHorzMargin    = 8;
  mcVertMargin    = 8;
  mcHorzSpacing   = 10;
  mcVertSpacing   = 10;
  mcButtonWidth   = 50;
  mcButtonHeight  = 14;
  mcButtonSpacing = 4;
  DrawFormatLine  = DT_CALCRECT or DT_LEFT or DT_SINGLELINE;
  DrawFormatText  = DT_EXPANDTABS or DT_CALCRECT or DT_WORDBREAK;
var
  DialogUnits     : TPoint;
  HorzMargin      : Integer;
  VertMargin      : Integer;
  HorzSpacing     : Integer;
  VertSpacing     : Integer;
  ButtonTop       : Integer;
  ButtonWidth     : Integer;
  ButtonHeight    : Integer;
  ButtonSpacing   : Integer;
  ButtonCount     : Integer;
  ButtonGroupWidth: Integer;
  MessageWidth    : Integer;
  MessageHeight   : Integer;
  LabelWidth      : Integer;
  ScreenWidth     : Integer;
  ScreenHeight    : Integer;
  X               : Integer;
  L               : Integer;
  B, CancelButton : TMsgDlgBtn;
  IconID          : PChar;
  TextRect        : TRect;
  LButton         : TButton;
  LMsg            : string;
begin
  LMsg := Trim(Msg);

  Result := TMessageForm.CreateNew(Application);
  with Result do
  begin
    Font := Application.DefaultFont;
    BiDiMode := Application.BiDiMode;
    BorderStyle := bsDialog;
    Canvas.Font := Font;
    KeyPreview := True;
    ShowHint := True;
    PopupMode := pmAuto;
    Position := poScreenCenter;
    OnKeyDown := TMessageForm(Result).CustomKeyDown;
    // definicao das variaveis
    DialogUnits := GetAveCharSize(Canvas);
    HorzMargin := MulDiv(mcHorzMargin, DialogUnits.X, 4);
    VertMargin := MulDiv(mcVertMargin, DialogUnits.Y, 8);
    HorzSpacing := MulDiv(mcHorzSpacing, DialogUnits.X, 4);
    VertSpacing := MulDiv(mcVertSpacing, DialogUnits.Y, 8);
    ButtonWidth := MulDiv(mcButtonWidth, DialogUnits.X, 4);
    ButtonHeight := MulDiv(mcButtonHeight, DialogUnits.Y, 8);
    ButtonSpacing := MulDiv(mcButtonSpacing, DialogUnits.X, 4);
    // tamanho do grupo de botoes
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
    begin
      if B in Buttons then
      begin
        if ButtonWidths[B] = 0 then
        begin
          TextRect := Rect(0, 0, 0, 0);
          DrawText(Canvas.Handle, PChar(LoadResString(ButtonCaptions[B])), -1, TextRect,
            DrawFormatLine or DrawTextBiDiModeFlagsReadingOnly);
          with TextRect do
            ButtonWidths[B] := Right - Left + 8;
        end;
        if ButtonWidths[B] > ButtonWidth then
          ButtonWidth := ButtonWidths[B];
      end;
    end;
    // tamanho do label
    TextRect := Rect(0, 0, 0, 0);
    DrawText(Canvas.Handle, SMsgDlgCopyToClipBrd, -1, TextRect, DrawFormatLine or DrawTextBiDiModeFlagsReadingOnly);
    LabelWidth := TextRect.Right - TextRect.Left + 8;
    SetRect(TextRect, 0, 0, Screen.WorkAreaWidth + 1 div 2, 0);
    // tamanho da mensagem
    DrawText(Canvas.Handle, LMsg, Length(LMsg) + 1, TextRect, DrawFormatText or DrawTextBiDiModeFlagsReadingOnly);
    MessageWidth := TextRect.Right;
    MessageHeight := TextRect.Bottom;
    // ícone
    IconID := IconIDs[DlgType];
    if IconID <> nil then
    begin
      Inc(MessageWidth, 32 + HorzSpacing);
      if MessageHeight < 32 then
        MessageHeight := 32;
    end;
    ButtonCount := 0;
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      if B in Buttons then
        Inc(ButtonCount);

    ButtonGroupWidth := 0;
    if ButtonCount > 0 then
      ButtonGroupWidth := (ButtonWidth * ButtonCount + ButtonSpacing * (ButtonCount - 1));

    // tamanho da tela
    ScreenWidth := Screen.WorkAreaWidth;
    ScreenHeight := Screen.WorkAreaHeight;
    case TaskBarPosition of
      alTop, alBottom:
        ScreenHeight := ScreenHeight - TaskBarHeight;
      alLeft, alRight:
        ScreenWidth := ScreenWidth - TaskBarWidth;
    end;

    // tamanho do formulario
    ClientWidth := Max(MessageWidth + 120, ButtonGroupWidth + LabelWidth) + HorzMargin * 2;
    if ClientWidth > ScreenWidth then
    begin
      ClientWidth := ScreenWidth;
      if ClientWidth < (ButtonGroupWidth + LabelWidth) then
        AutoScroll := True;
    end;
    ClientHeight := MessageHeight + ButtonHeight + VertSpacing + VertMargin * 2;
    if ClientHeight > ScreenHeight then
      ClientHeight := ScreenHeight;

    // titulo
    Caption := Application.Title;

    { if DlgType <> mtCustom then
      Caption := Caption + '   -   ' + LoadResString(Captions[DlgType]); }

    FExeVErsion := GetExeVersion;

    // criacao da imagem
    if IconID <> nil then
      with TImage.Create(Result) do
      begin
        Name := 'Image';
        Parent := Result;
        Transparent := True;
        IncrementalDisplay := True;
        Picture.Icon.Handle := LoadIcon(0, IconID);
        SetBounds(HorzMargin, VertMargin, 32, 32);
      end;

    // criacao do richedit
    TMessageForm(Result).RichEditMessage := TRichEdit.Create(Result);
    with TMessageForm(Result).RichEditMessage do
    begin
      Name := 'RichMessage';
      Parent := Result;
      Cursor := crArrow;
      WordWrap := True;
      BevelInner := bvNone;
      BevelOuter := bvNone;
      BorderStyle := bsNone;
      ParentColor := True;
      PlainText := True;
      ScrollBars := TScrollStyle.ssVertical;
      Lines.Text := LMsg;
      ReadOnly := True;
      BoundsRect := TextRect;
      BiDiMode := Result.BiDiMode;
      TabStop := False;
      OnEnter := TMessageForm(Result).CustomEnter;
      L := MessageWidth - TextRect.Right + HorzMargin;
      if UseRightToLeftAlignment then
        L := Result.ClientWidth - L - Width;
      SetBounds(L, VertMargin, Result.ClientWidth - 65, Result.ClientHeight - (ButtonHeight + VertMargin + VertSpacing));
    end;

    // definicao dos botoes
    if mbCancel in Buttons then
      CancelButton := mbCancel
    else
      if mbNo in Buttons then
      CancelButton := mbNo
    else
      CancelButton := mbOK;

    // posicao Top dos botoes
    ButtonTop := Result.Height - (ButtonHeight + VertMargin + VertSpacing + 10);

    // criacao do label
    with TLabel.Create(Result) do
    begin
      Name := 'LabelClpBrd';
      Parent := Result;
      AutoSize := True;
      Transparent := True;
      Layout := tlCenter;
//      Font.Style := [fsUnderline, fsItalic];
      Font.Size := 7;
      Cursor := crHandPoint;
      Caption := SMsgDlgCopyToClipBrd;
      Hint := SHintMsgDlgCopyToClipBrd;
      OnClick := TMessageForm(Result).CutomLabelClick;
      SetBounds(mcHorzSpacing, ButtonTop + (ButtonHeight div 2) - mcVertMargin, LabelWidth, 15);
    end;

    // posicao incial do grupo de botoes
    X := (ClientWidth - ButtonGroupWidth + LabelWidth) div 2;

    // criacao dos botoes
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      if B in Buttons then
      begin
        LButton := TButton.Create(Result);
        with LButton do
        begin
          Name := ButtonNames[B];
          Parent := Result;
          Caption := LoadResString(ButtonCaptions[B]);
          ModalResult := ModalResults[B];
          if B = DefaultButton then
          begin
            Default := True;
            ActiveControl := LButton;
          end;
          if B = CancelButton then
            Cancel := True;
          SetBounds(X, ButtonTop, ButtonWidth, ButtonHeight);
          Inc(X, ButtonWidth + ButtonSpacing);
          if B = mbHelp then
            OnClick := TMessageForm(Result).HelpButtonClick;
        end;
      end;
  end;
  WaitCloseMessage;
end;

procedure ShowMsg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TMsgDlgBtn);
begin
  with CreateMessageDlg(Msg, DlgType, Buttons, DefaultButton) do
  begin
    ShowModal;
    Free;
  end;
end;

function QueryMsg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TMsgDlgBtn): Integer;
begin
  with CreateMessageDlg(Msg, DlgType, Buttons, DefaultButton) do
  begin
    try
      ShowModal;
      Result := ModalResult;
    finally
      Free;
    end;
  end;
end;

procedure MessageBoxError(const Msg: string);
begin
  MessageBeep(16);
  ShowMsg(Msg, mtError, [mbOK], mbOK);
end;

function MessageBoxYesNo(const Msg: string): Integer;
begin
  MessageBeep(16);
  Exit(QueryMsg(Msg, mtConfirmation, [mbYes, mbNo], mbNo));
end;

function MessageBoxYesNoCancel(const Msg: string): Integer;
begin
  MessageBeep(16);
  Exit(QueryMsg(Msg, mtConfirmation, [mbYes, mbNo, mbCancel], mbCancel));
end;

procedure MessageBoxInformation(const Msg: string);
begin
  MessageBeep(64);
  ShowMsg(Msg, mtInformation, [mbOK], mbOK);
end;

function MessageBox(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TMsgDlgBtn): Integer;
begin
  Exit(QueryMsg(Msg, DlgType, Buttons, DefaultButton));
end;

{ TWaitForm }

procedure TWaitForm.CustomAppEventsModalBegin(Sender: TObject);
begin
  WaitCloseMessage;
end;

procedure TWaitForm.CustomCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // método para implementação futura, onde poderá ser cancelada uma ação demorada
  CanClose := True;
end;

procedure DisableProcessWindowsGhosting;
var
  User32: HMODULE;
  Proc  : TProcedure;
begin
  User32 := GetModuleHandle('USER32');
  if User32 <> 0 then
  begin
    Proc := GetProcAddress(User32, 'DisableProcessWindowsGhosting');
    if Assigned(Proc) then
      Proc;
  end;
end;

procedure EmptyKeyQueue;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, 0, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE or PM_NOYIELD) do;
end;

procedure EmptyMouseQueue;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, 0, WM_MOUSEFIRST, WM_MOUSELAST, PM_REMOVE or PM_NOYIELD) do;
end;

var
  WaitForm      : TForm;
  LastActiveForm: TForm;
  WindowList    : TTaskWindowList;
  WindowLocked  : Boolean;

const
  MinHeight = 120;
  MinWidth  = 450;

function CreateWaitDlg(const Msg: string): TForm;
const
  FWhiteColor = 16777215;
  FFontTahoma = 'Tahoma';

var
  FPanelLeft, FPanelTop: Integer;
begin
  if not Assigned(LastActiveForm) then
    if Assigned(Screen.ActiveForm) then
      if not(Screen.ActiveForm.ClassNameIs(TWaitForm.ClassName)) then
      begin
        LastActiveForm := Screen.ActiveForm;
        if LastActiveForm.FormStyle = fsMDIChild then
          LastActiveForm := Application.MainForm;
        if Assigned(LastActiveForm) then
          WindowLocked := LockWindowUpdate(LastActiveForm.Handle);
      end;

  Result := TWaitForm.CreateNew(LastActiveForm);
  with Result do
  begin
    Name := 'WaitForm';
    BorderIcons := [];
    BorderStyle := bsNone;
    DoubleBuffered := False;
    Color := clFuchsia;
    Tag := -99;
    PopupMode := pmAuto;
    OnCloseQuery := TWaitForm(Result).CustomCloseQuery;
    Position := poOwnerFormCenter;
    Caption := Application.Title;
    // dimensões padrao
    ClientHeight := MinHeight;
    ClientWidth := MinWidth;
    // dimensiona de acordo ao formulario ativo
    if Assigned(LastActiveForm) then
    begin
      ClientHeight := LastActiveForm.Height;
      ClientWidth := LastActiveForm.Width;
    end;
    // posição do panel
    FPanelLeft := 0;
    FPanelTop := (ClientHeight div 2) - (MinHeight div 2);
    // tratamento de transparência
    TransparentColorValue := Color;
    TransparentColor := True;
    AlphaBlendValue := 240;
    AlphaBlend := True;
  end;

  // panel
  TWaitForm(Result).PanelContainer := TPanel.Create(Result);
  with TWaitForm(Result).PanelContainer do
  begin
    Parent := Result;
    Color := $00805937;
    ParentBackground := False;
    if Assigned(LastActiveForm) then
      BevelKind := bkNone
    else
      BevelKind := bkFlat;
    SetBounds(FPanelLeft, FPanelTop, TWaitForm(Result).ClientWidth, MinHeight);
  end;

//  // label version
//  with TLabel.Create(Result) do
//  begin
//    Parent := TWaitForm(Result).PanelContainer;
//    Transparent := True;
//    Caption := GetExeVersion;
//    ParentFont := False;
//    Layout := tlCenter;
//    Font.Color := FWhiteColor;
//    Font.Name := FFontTahoma;
//    Font.Size := 7;
//    Left := 8;
//    Top := 5;
//  end;

  // label aguarde
  with TLabel.Create(Result) do
  begin
    Parent := TWaitForm(Result).PanelContainer;
    AlignWithMargins := True;
    Align := alTop;
    Margins.Top := 15;
    Alignment := taCenter;
    Transparent := True;
    Caption := 'Aguarde';
    ParentFont := False;
    Layout := tlCenter;
    Font.Color := FWhiteColor;
    Font.Name := FFontTahoma;
    Font.Size := 18;
    Font.Style := [fsBold];
  end;

  // label msg
  TWaitForm(Result).LabelMessage := TLabel.Create(Result);
  with TWaitForm(Result).LabelMessage do
  begin
    Parent := TWaitForm(Result).PanelContainer;
    AlignWithMargins := True;
    Align := alClient;
    Alignment := taCenter;
    Transparent := True;
    Caption := 'Processando ...';
    ParentFont := False;
    Layout := tlCenter;
    WordWrap := True;
    Font.Color := FWhiteColor;
    Font.Name := FFontTahoma;
    Font.Size := 12;
    Font.Style := [fsBold];
  end;

  // ApplicationEvents
  TWaitForm(Result).AppEvents := TApplicationEvents.Create(Result);
  with TWaitForm(Result).AppEvents do
    OnModalBegin := TWaitForm(Result).CustomAppEventsModalBegin;
end;

procedure WaitShowMessage(const Msg: string);
begin
  if not Assigned(WaitForm) then
  begin
    WaitForm := CreateWaitDlg(Msg);
    with WaitForm do
    begin
      WindowList := DisableTaskWindows(0);
      Screen.FocusedForm := WaitForm;
      Show;
      SendMessage(Handle, CM_ACTIVATE, 0, 0);
      Screen.Cursor := crHourGlass;
    end;
  end;

  with TWaitForm(WaitForm) do
  begin
    if Trim(Msg) = '' then
      LabelMessage.Caption := 'Processando ...'
    else
      LabelMessage.Caption := Trim(Msg);
  end;
  Application.ProcessMessages;
end;

procedure WaitCloseMessage;
begin
  try
    if Assigned(WaitForm) then
    begin
      try
        if WindowList <> nil then
          EnableTaskWindows(WindowList);

        WaitForm.Tag := -1;
        WaitForm.Close;
        FreeAndNil(WaitForm);
      finally
        EmptyKeyQueue;
        EmptyMouseQueue;
        LastActiveForm := nil;
        WindowList := nil;
        Screen.Cursor := crDefault;
      end;
    end;
  finally
    if WindowLocked then
    begin
      LockWindowUpdate(0);
      WindowLocked := False;
    end;
  end;
end;

procedure WaitShowProgress(const Msg: string; ExecProc: TProc);
begin
  WaitShowMessage(Msg);
  try
    if Assigned(ExecProc) then
      ExecProc;
  finally
    WaitCloseMessage;
  end;
end;

procedure WaitShowProgress(const Msg: string; ExecFunc: TFunc<Boolean>);
begin
  WaitShowMessage(Msg);
  try
    if Assigned(ExecFunc) then
      ExecFunc;
  finally
    WaitCloseMessage;
  end;
end;

initialization

DisableProcessWindowsGhosting;

end.
