unit View.Login;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.TabControl, FMX.Objects, FMX.Layouts,
  Controller.Main, Controller.Interfaces, Model.Entity.User;

type
  TFrmLogin = class(TForm)
    layCentro: TLayout;
    StyleBook1: TStyleBook;
    Rectangle8: TRectangle;
    Layout1: TLayout;
    Button5: TButton;
    lbError: TLabel;
    TabControl2: TTabControl;
    TabItem7: TTabItem;
    Label12: TLabel;
    Layout15: TLayout;
    Label13: TLabel;
    Rectangle14: TRectangle;
    edt_emailLogin: TEdit;
    Rectangle15: TRectangle;
    edt_PasswordLogin: TEdit;
    Label15: TLabel;
    Rectangle18: TRectangle;
    Label17: TLabel;
    CheckBox4: TCheckBox;
    Label16: TLabel;
    Label19: TLabel;
    checkLembre: TCheckBox;
    TabItem4: TTabItem;
    Layout16: TLayout;
    Label14: TLabel;
    Rectangle5: TRectangle;
    edt_NomeCompleto: TEdit;
    btnNext_Cadastro: TRectangle;
    Label18: TLabel;
    CheckBox1: TCheckBox;
    Label21: TLabel;
    Rectangle7: TRectangle;
    edt_Email: TEdit;
    lyt_verificacao: TLayout;
    Rectangle28: TRectangle;
    edtCodigoVerificacao: TEdit;
    Label41: TLabel;
    Label42: TLabel;
    lbReenviarEmail: TLabel;
    Rectangle29: TRectangle;
    edtConfirmaEmail: TEdit;
    Label43: TLabel;
    Label22: TLabel;
    Button1: TButton;
    Label1: TLabel;
    TabItem8: TTabItem;
    Label40: TLabel;
    Layout21: TLayout;
    Label45: TLabel;
    Rectangle16: TRectangle;
    edt_password: TEdit;
    Rectangle19: TRectangle;
    edt_passwordConfirm: TEdit;
    Label46: TLabel;
    Rectangle20: TRectangle;
    Label47: TLabel;
    lbForcaSenha: TLabel;
    lbCaracterMin: TLabel;
    lbumNumero: TLabel;
    lbUmaLetra: TLabel;
    Button3: TButton;
    Label2: TLabel;
    procedure sbLoginClick(Sender: TObject);
    procedure Label19Click(Sender: TObject);
    procedure btnNext_CadastroClick(Sender: TObject);
    procedure Rectangle20Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure TabControl2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormCreate(Sender: TObject);
    procedure edt_passwordKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure edt_passwordConfirmKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure HandleKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure edt_PasswordLoginKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure edt_emailLoginKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
    aProcLogin: Boolean;
    FRegisterUsers : iControllerUsers;
    FCountMail : integer;
    FLoginResult: Boolean;
    FController: iControllerEntity<TUser>;
    procedure ThreadLoginTerminate(Sender: TObject);
    function ValidEmail(value: string; verificarCadastro : boolean = true): boolean;
    function CheckPasswordStrength(const Password: string): string;
    function ValidNomeCompleto(const Nome: string): Boolean;
    procedure limparEdits;

  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

uses
  controller.loading, View.Main, Controller.Utils, System.Character,
  SHELLAPI, FMX.Platform.Win, Winapi.Windows, IdDNSResolver, IdStack;

{$R *.fmx}

procedure TFrmLogin.TabControl2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  Self.StartWindowDrag;
end;

procedure TFrmLogin.btnNext_CadastroClick(Sender: TObject);
var
  ErrorMessage: string;
begin
  if not ValidNomeCompleto(edt_NomeCompleto.Text) then
    ErrorMessage := 'Digite seu nome completo.'
  else if not ValidEmail(edt_Email.Text) then
    ErrorMessage := 'Digite um endereço de email válido.'
  else if edtConfirmaEmail.Text <> edt_Email.Text then
    ErrorMessage := 'Os emails não correspondem.'
  else
    ErrorMessage := '';

    if ErrorMessage <> '' then
    begin
      lbError.Text := ErrorMessage;
      Exit;
    end;

  lbError.Text := '';
  tabControl2.Next;
  edt_password.SetFocus;
end;

function TFrmLogin.ValidNomeCompleto(const Nome: string): Boolean;
var
  Nomes: TArray<string>;
  i: Integer;
begin
  Nomes := Nome.Split([' ']);

  if Length(Nomes) < 2 then
    Exit(False);

  for i := Low(Nomes) to High(Nomes) do
  begin
    if Length(Nomes[i]) < 2 then
      Exit(False);
  end;

  Result := True;
end;

function TFrmLogin.ValidEmail(value : string; verificarCadastro : boolean = true) : boolean;
begin
  Result := false;

  TLoading.ShowLoad(Rectangle8, 'Validando email...');
  try
    if not Main.UTILS.IsValidEmail(value) then
    begin
      lbError.Text := 'Digite um endereço de email válido.';
      TLoading.HideLoad;
      exit;
    end else
    lbError.Text := '';

    if verificarCadastro then
    begin
      if Main.USER.ExisteValorNoCampo('email', value) then
      begin
          lbError.Text := 'Este Email já está cadastrado, faça o login na página anterior.';
          TLoading.HideLoad;
          exit;
      end else
        lbError.Text := '';
    end else begin
      if not Main.USER.ExisteValorNoCampo('email', value) then
      begin
          lbError.Text := 'Este Email não está cadastrado, faça o seu cadastro.';
          TLoading.HideLoad;
          exit;
      end else
        lbError.Text := '';
    end;

    TLoading.HideLoad;
    Result := true;
  except
    on E:Exception do
    begin
      TLoading.HideLoad;
      Main.FORMS.DialogMessage('', E.Message, dmError);
    end;
  end;
end;

procedure TFrmLogin.Button1Click(Sender: TObject);
begin
  tabControl2.Previous;
end;

procedure TFrmLogin.Button3Click(Sender: TObject);
begin
  tabControl2.Previous;
end;

procedure TFrmLogin.Button4Click(Sender: TObject);
begin
  tabControl2.Previous;
end;

procedure TFrmLogin.Button5Click(Sender: TObject);
begin
  close;
end;

procedure TFrmLogin.Button6Click(Sender: TObject);
begin
  TabControl2.TabIndex := 0;
end;

procedure TFrmLogin.HandleKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Trim(TEdit(Sender).Text) <> '') then
  begin
    if Sender = edt_NomeCompleto then
      edt_Email.SetFocus
    else if Sender = edt_Email then
      edtConfirmaEmail.SetFocus;
  end;

  if Sender = edt_NomeCompleto then
   if not (KeyChar in ['a'..'z', 'A'..'Z', ' ', #8]) then begin
     KeyChar := #0;
     exit;
   end;
end;

procedure TFrmLogin.edt_emailLoginKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if ((Key = vkReturn) or (Key = vkTab)) and (TEdit(Sender).Text <> '') then
  begin
    edt_PasswordLogin.SetFocus;
    Key := 0;
  end;
end;

procedure TFrmLogin.edt_passwordConfirmKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (key = 13) and (TEdit(sender).Text <> EmptyStr) then
    Rectangle20Click(Sender);
end;

procedure TFrmLogin.edt_passwordKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (key = 13) and (TEdit(sender).Text <> EmptyStr) then
    Rectangle20Click(Sender);
end;

procedure TFrmLogin.edt_PasswordLoginKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = 13) and (Trim(TEdit(Sender).Text) <> '') then
    sbLoginClick(nil);
end;

function TFrmLogin.CheckPasswordStrength(const Password: string): string;
var
  LengthScore, UppercaseScore, LowercaseScore, DigitScore, SpecialCharScore: Integer;
  sChar: Char;
  TotalScore: Integer;
begin
  LengthScore := 0;
  UppercaseScore := 0;
  LowercaseScore := 0;
  DigitScore := 0;
  SpecialCharScore := 0;

  if Length(Password) < 7 then
    LengthScore := 1
  else if Length(Password) < 8 then
    LengthScore := 2
  else
    LengthScore := 3;

  for sChar in Password do
  begin
    if TCharacter.IsUpper(sChar) then
      UppercaseScore := 1
    else if TCharacter.IsLower(sChar) then
      LowercaseScore := 1
    else if TCharacter.IsDigit(sChar) then
      DigitScore := 1
    else
      SpecialCharScore := 1;
  end;

  TotalScore := LengthScore + UppercaseScore + LowercaseScore + DigitScore + SpecialCharScore;

  if TotalScore <= 4 then
    Result := 'SENHA FRACA'
  else if TotalScore <= 6 then
    Result := 'SENHA MÉDIA'
  else
    Result := 'SENHA FORTE';

  lbForcaSenha.Text := Result;

  if Result = 'SENHA FRACA' then
    lbForcaSenha.TextSettings.FontColor := $FFD41D1D;

  if Result = 'SENHA MÉDIA' then
    lbForcaSenha.TextSettings.FontColor := $FFF6DD64;

  if Result = 'SENHA FORTE' then
    lbForcaSenha.TextSettings.FontColor := $FF21A406;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  FLoginResult := false;
  tabControl2.TabIndex := 0;
  FCountMail := 60;

  edt_NomeCompleto.OnKeyDown := HandleKeyDown;
  edtConfirmaEmail.OnKeyDown := HandleKeyDown;
  edt_Email.OnKeyDown := HandleKeyDown;

  edtConfirmaEmail.OnKeyDown := HandleKeyDown;
  FController := Main.EntityUSER;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
var
  sMax : integer;
begin
  checkLembre.IsChecked := Main.UTILS.CarregarCredenciais.Lembrar;

  if checkLembre.IsChecked then
  begin
    edt_emailLogin.Text := Main.UTILS.CarregarCredenciais.Email;
    edt_PasswordLogin.Text := Main.UTILS.CarregarCredenciais.Senha;
  end;

  edt_emailLogin.SetFocus;
end;

procedure TFrmLogin.Label19Click(Sender: TObject);
begin
  lbError.Text := '';
  tabControl2.Next;
  edt_NomeCompleto.SetFocus;
end;

procedure TFrmLogin.Rectangle20Click(Sender: TObject);
var
  User : TUser;
begin
  TLoading.ShowLoad(Rectangle8, 'Verificando senha...');

  try
    if Main.USER.SenhaValida(edt_password.Text, edt_passwordConfirm.Text) = false then
    begin
      TLoading.HideLoad;
      exit;
    end;

  except
    on E:Exception do begin
      lbError.Text := E.Message;
      TLoading.HideLoad;
      exit;
    end;
  end;

  lbError.Text := '';

  User := FController.DAO.NewObject;

  User.ID := Main.UTILS.NewUID;
  User.Name := edt_NomeCompleto.Text;
  User.Email := edt_Email.Text;
  User.PASSWORD := Main.UTILS.Criptografar(edt_password.Text);
  Main.USER.NewUser(User);
  tabControl2.TabIndex := 0;
  edt_emailLogin.Text := edt_Email.Text;
  limparEdits;
  edt_PasswordLogin.Text := '';
  edt_PasswordLogin.SetFocus;

  TLoading.HideLoad;
end;

procedure TFrmLogin.limparEdits;
begin
  edt_NomeCompleto.Text := '';
  edt_Email.Text := '';
  edtConfirmaEmail.Text := '';
  edt_password.Text := '';
  edt_passwordConfirm.Text := '';
end;

procedure TFrmLogin.sbLoginClick(Sender: TObject);
var
  ThreadLogin: TThread;
begin
  if aProcLogin then
    abort;

  if (edt_emailLogin.Text = '') or (edt_PasswordLogin.Text = '') then
  begin
    exit;
  end;

  aProcLogin := true;
  TLoading.ShowLoad(Rectangle8, 'Acessando...');
  ThreadLogin := TThread.CreateAnonymousThread(
    procedure
    begin
      FLoginResult := Main.USER.Login(edt_emailLogin.Text,edt_PasswordLogin.Text);
      sleep(1000);
    end);
  ThreadLogin.OnTerminate := ThreadLoginTerminate;
  ThreadLogin.Start;
end;

procedure TFrmLogin.ThreadLoginTerminate(Sender: TObject);
begin
  TLoading.HideLoad;
  aProcLogin := false;

  if Sender is TThread then
  begin
    if Assigned(TThread(Sender).FatalException) then
    begin
      lbError.Text := (Exception(TThread(Sender).FatalException).Message);
      exit;
    end;
  end;

  if FLoginResult then
  begin
    Main.UTILS.SalvarCredenciais(edt_emailLogin.Text, edt_PasswordLogin.Text, checkLembre.IsChecked);

    if NOT Assigned(frmMain) then
      Application.CreateForm(TfrmMain, frmMain);

    Application.MainForm := frmMain;
    frmMain.lbCurrentemail.Text := edt_emailLogin.Text;
    frmMain.lbCurrentUser.Text := Main.CurrentUser.Name;
    frmMain.lbBoasVindas.Text := 'Seja bem-vindo, '+Main.UTILS.PrimeiroNome(Main.CurrentUser.Name)+'!';
    frmMain.Show;

    frmMain.LoadForm;
    FrmLogin.Close;
  end
  else
  begin
    lbError.Text := 'Erro de login: Verifique suas credenciais.';
  end;
end;

end.
