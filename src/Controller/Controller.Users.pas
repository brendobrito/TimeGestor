unit Controller.Users;

interface

uses
  Controller.Interfaces, Model.DAO.Interfaces, Model.Entity.User, System.Generics.Collections;

type
  TControllerUsers = class(TInterfacedObject, iControllerUsers)
  private
    [weak]
    FParent: IController;
    FModel: iDAOGeneric<TUSER>;
    FCurrentUser: TCurrentUSER;
    function PrimeiroNome(const NomeCompleto: string): string;
  public
    constructor Create(Parent: IController);
    destructor Destroy; override;
    class function New(Parent: IController): iControllerUsers;
    function &End: IController;
    function SenhaValida(Pass1, Pass2: string): boolean;
    function ExisteValorNoCampo(const Campo, Valor: string): boolean;
    function Login(const Email, Password: string): Boolean;
    function NewUser(AUser: TUSER): iControllerUsers;
    function DAO: iDAOGeneric<TUSER>;
  end;

implementation

uses
  Model.DAO.Factory, Model.DAO.SQL, System.SysUtils, IOUtils, DateUtils;

{ TControllerUsers }

constructor TControllerUsers.Create(Parent: IController);
begin
  FParent := Parent;
  FModel := FParent.EntityUSER.DAO;
end;

destructor TControllerUsers.Destroy;
begin

  inherited;
end;

class function TControllerUsers.New(Parent: IController): iControllerUsers;
begin
  Result := Self.Create(Parent);
end;

function TControllerUsers.&End: IController;
begin
  Result := FParent;
end;

function TControllerUsers.DAO: iDAOGeneric<TUSER>;
begin
  Result := FModel;
end;

function TControllerUsers.ExisteValorNoCampo(const Campo, Valor: string): boolean;
var
  UserList: TObjectList<TUSER>;
begin
  Result := False;
  UserList := TObjectList<TUSER>.Create;
  try
    FModel.SQL.Clear
      .Where(Format('%s = ''%s''', [Campo, Valor]))
    .&End
    .Find(UserList);

    Result := UserList.Count > 0;
  finally
    UserList.Free;
  end;
end;

function TControllerUsers.SenhaValida(Pass1, Pass2: string): boolean;
begin
  Result := False;

  if Length(Pass1) < 7 then
    raise Exception.Create('Senha muito curta. Informe uma senha com 7 caracteres ou mais');

  if not FParent.UTILS.ContainsLetter(Pass1) then
    raise Exception.Create('A senha deve conter pelo menos uma letra.');

  if not FParent.UTILS.ContainsNumber(Pass1) then
    raise Exception.Create('A senha deve conter pelo menos um número.');

  if Pass1 <> Pass2 then
    raise Exception.Create('As senhas informadas não coincidem.');

  Result := True;
end;

function TControllerUsers.PrimeiroNome(const NomeCompleto: string): string;
var
  EspacoPos: Integer;
begin
  EspacoPos := Pos(' ', NomeCompleto);
  Result := Copy(NomeCompleto, 1, EspacoPos - 1);
end;

function TControllerUsers.Login(const Email, Password: string): Boolean;
var
  UserList: TObjectList<TUSER>;
begin
  Result := False;
  UserList := TObjectList<TUSER>.Create;
  try
    FModel.SQL.Clear
      .Where(Format('EMAIL = ''%s'' AND PASSWORD = ''%s''', [Email, FParent.UTILS.Criptografar(Password)]))
    .&End
    .Find(UserList);

    if UserList.Count > 0 then
    begin
      FCurrentUser.ID := UserList[0].ID;
      FCurrentUser.NAME := UserList[0].NAME;
      FCurrentUser.EMAIL := UserList[0].EMAIL;

      FParent.setCurrentUser(FCurrentUser);
      Result := True;
    end;
  finally
    UserList.Free;
  end;
end;

function TControllerUsers.NewUser(AUser: TUSER): iControllerUsers;
begin
  Result := Self;
  FModel.Insert;
end;

end.

