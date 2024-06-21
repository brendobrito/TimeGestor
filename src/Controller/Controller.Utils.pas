unit Controller.Utils;

interface

uses
  Controller.Interfaces;

type
  TControllerUtils = class(TInterfacedObject, iControllerUtils)
    private
      FParent : iController;

    public
      constructor Create(Parent : iController);
      destructor Destroy; override;
      class function New(Parent : iController): iControllerUtils;
      function &End: IController;
      function NewUID : string;
      procedure SalvarCredenciais(Email, Senha: string; Lembrar: Boolean);
      function CarregarCredenciais: TCredenciais;
      function Criptografar(const ATexto : string): string;
      function Descriptografar(const ATextoCriptografado, AChave: string): string;
      function IsValidEmail(const Email: string): Boolean;
      function ContainsLetter(const Text: string): Boolean;
      function ContainsNumber(const Password: string): Boolean;
      function OnlyNumbers(const Valor: string): string;
      function PrimeiroNome(const NomeCompleto: string): string;

  end;

implementation

uses
  System.SysUtils, DCPrijndael, DCPcrypt2, DCPblockciphers, DCPsha1,System.NetEncoding, IniFiles,
  System.Generics.Collections;

{ TControllerUtils }

function TControllerUtils.ContainsNumber(const Password: string): Boolean;
var
  sChar: Char;
begin
  Result := False;
  for sChar in Password do
  begin
    if (sChar >= '0') and (sChar <= '9') then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TControllerUtils.ContainsLetter(const Text: string): Boolean;
var
  sChar: Char;
begin
  Result := False;
  for sChar in Text do
  begin
    if (sChar >= 'A') and (sChar <= 'Z') or (sChar >= 'a') and (sChar <= 'z') then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TControllerUtils.PrimeiroNome(const NomeCompleto: string): string;
var
  EspacoPos: Integer;
begin
  EspacoPos := Pos(' ', NomeCompleto);
  if EspacoPos > 0 then
    Result := Copy(NomeCompleto, 1, EspacoPos - 1)
  else
    Result := NomeCompleto;

  Result := AnsiUpperCase(Copy(Result, 1, 1)) + AnsiLowerCase(Copy(Result, 2, MaxInt));
end;

function TControllerUtils.OnlyNumbers(const Valor: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Valor) do
  begin
    if CharInSet(Valor[i], ['0'..'9']) then
      Result := Result + Valor[i];
  end;
end;

constructor TControllerUtils.Create(Parent: iController);
begin
  FParent := Parent;
end;

destructor TControllerUtils.Destroy;
begin

  inherited;
end;

function TControllerUtils.&End: IController;
begin
  Result := FParent;
end;

class function TControllerUtils.New(Parent: iController): iControllerUtils;
begin
  Result := self.Create(Parent);
end;

function TControllerUtils.NewUID: string;
begin
  Result := GUIDToString(TGUID.NewGuid);
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
end;

function TControllerUtils.IsValidEmail(const Email: string): Boolean;
const
  ValidChars = ['A'..'Z', 'a'..'z', '0'..'9', '!', '#', '$', '%', '&', '''', '*', '+',
               '-', '/', '=', '?', '^', '_', '`', '{', '|', '}', '~', '@', '.', '-', '_'];
var
  AtPos, DotPos: Integer;
  Domain, TLD: string;
  I: Integer;
  TLDs: TList<string>;
begin
  Result := False;

  if Email = '' then
    Exit;

  if Length(Email) > 255 then
    Exit;

  AtPos := Pos('@', Email);
  if AtPos = 0 then
    Exit;

  // Verifica se há somente um símbolo '@'
  if LastDelimiter('@', Email) > AtPos then
    Exit;

  Domain := Copy(Email, AtPos + 1, Length(Email) - AtPos);
  DotPos := LastDelimiter('.', Domain); // Procurando o último ponto

  if (DotPos = 0) or (Length(Domain) - DotPos < 2) then
    Exit;

  TLD := LowerCase(Copy(Domain, DotPos + 1, Length(Domain) - DotPos));

  TLDs := TList<string>.Create;
  try
    TLDs.AddRange(['com', 'org', 'net', 'gov', 'edu', 'br', 'com.br']);
    if not TLDs.Contains(TLD) then
      Exit;
  finally
    TLDs.Free;
  end;

  Result := True;
end;

function TControllerUtils.Criptografar(const ATexto : string): string;
var
  Cipher: TDCP_rijndael;
  Data, Key: string;
  sChave : string;
begin
  sChave := 'B1CE38B2-E99A-4386-B5FD-92228DFE7894';
  Cipher := TDCP_rijndael.Create(nil);
  try
    // Preparar a chave
    Key := Copy(sChave, 1, Cipher.MaxKeySize div 8);
    Cipher.InitStr(Key, TDCP_sha1); // Inicializar a cipher com a chave

    // Criptografar
    Data := ATexto;
    Cipher.EncryptCBC(Data[1], Data[1], Length(Data));
    Result := TNetEncoding.Base64.Encode(Data);
  finally
    Cipher.Burn;
    Cipher.Free;
  end;
end;

function TControllerUtils.Descriptografar(const ATextoCriptografado, AChave: string): string;
var
  Cipher: TDCP_rijndael;
  Data, Key: string;
begin
  Cipher := TDCP_rijndael.Create(nil);
  try
    // Preparar a chave
    Key := Copy(AChave, 1, Cipher.MaxKeySize div 8);
    Cipher.InitStr(Key, TDCP_sha1);

    // Descriptografar
    Data := TNetEncoding.Base64.Decode(ATextoCriptografado);
    Cipher.DecryptCBC(Data[1], Data[1], Length(Data));
    Result := Data;
  finally
    Cipher.Burn;
    Cipher.Free;
  end;
end;

procedure TControllerUtils.SalvarCredenciais(Email, Senha: string; Lembrar: Boolean);
var
  IniFile: TIniFile;
  SenhaCriptografada: string;
begin
  IniFile := TIniFile.Create(PCHAR(GetCurrentDir + '\Config.ini'));
  try
    IniFile.WriteString('Credenciais', 'Email', Email);
    if Lembrar then
    begin
      SenhaCriptografada := Criptografar(Senha);
      IniFile.WriteString('Credenciais', 'Senha', SenhaCriptografada);
      IniFile.WriteBool('Credenciais', 'Lembrar', True);
    end
    else
    begin
      IniFile.WriteString('Credenciais', 'Senha', '');
      IniFile.WriteBool('Credenciais', 'Lembrar', False);
    end;
  finally
    IniFile.Free;
  end;
end;

function TControllerUtils.CarregarCredenciais: TCredenciais;
var
  IniFile: TIniFile;
  SenhaCriptografada: string;
begin
  IniFile := TIniFile.Create(PCHAR(GetCurrentDir + '\Config.ini'));
  try
    Result.Email := IniFile.ReadString('Credenciais', 'Email', '');
    Result.Lembrar := IniFile.ReadBool('Credenciais', 'Lembrar', False);
    if Result.Lembrar then
    begin
      SenhaCriptografada := IniFile.ReadString('Credenciais', 'Senha', '');
      Result.Senha := Descriptografar(SenhaCriptografada, 'B1CE38B2-E99A-4386-B5FD-92228DFE7894');
    end
    else
      Result.Senha := '';
  finally
    IniFile.Free;
  end;
end;

end.

