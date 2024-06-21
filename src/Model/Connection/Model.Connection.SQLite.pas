unit Model.Connection.SQLite;

interface

uses
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite,
  FireDAC.Comp.UI,
  Data.DB,
  FireDAC.Comp.Client,
  Model.Connection.Interfaces,
  System.SysUtils;

type
  TModelConnectionSQLite = class(TInterfacedObject, iConnection<TFDConnection>)
  private
    FConnection: TFDConnection;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iConnection<TFDConnection>;
    function Connection: TFDConnection;
    procedure CreateTasksTable;
    procedure CreateUsersTable;
  end;

implementation

constructor TModelConnectionSQLite.Create;
begin
  FConnection := TFDConnection.Create(nil);
  FConnection.Params.DriverID := 'SQLite';
  FConnection.Params.Database := 'database.db';
  FConnection.Connected := True;

  CreateTasksTable;
  CreateUsersTable;
end;

destructor TModelConnectionSQLite.Destroy;
begin
  FConnection.Free;
  inherited;
end;

class function TModelConnectionSQLite.New: iConnection<TFDConnection>;
begin
  Result := Self.Create;
end;

function TModelConnectionSQLite.Connection: TFDConnection;
begin
  Result := FConnection;
end;

procedure TModelConnectionSQLite.CreateTasksTable;
const
  SQLCreateTable =
    'CREATE TABLE IF NOT EXISTS Task (' +
    'ID TEXT PRIMARY KEY, ' +
    'Date DATE, ' +
    'StartTime TEXT, ' +
    'EndTime TEXT, ' +
    'Color TEXT, ' +
    'Title TEXT, ' +
    'Description TEXT, ' +
    'Observations TEXT, ' +
    'IsCompleted BOOLEAN,' +
    'UserID TEXT);';
begin
  FConnection.ExecSQL(SQLCreateTable);
end;

procedure TModelConnectionSQLite.CreateUsersTable;
const
  SQLCreateTable =
    'CREATE TABLE IF NOT EXISTS USERS (' +
    'ID TEXT PRIMARY KEY, ' +
    'NAME TEXT, ' +
    'EMAIL TEXT, ' +
    'PASSWORD TEXT);';
begin
  FConnection.ExecSQL(SQLCreateTable);
end;

end.

