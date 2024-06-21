unit Model.Database;

interface

uses
  FireDAC.Comp.Client,
  Model.Connection.Interfaces;

type
  TModelDatabase = class
  private
    FConnection: iConnection<TFDConnection>;
    procedure CreateTables;
  public
    constructor Create;
    procedure InitializeDatabase;
  end;

implementation

uses
  Model.Connection.SQLite;

{ TModelDatabase }

constructor TModelDatabase.Create;
begin
  FConnection := TModelConnectionSQLite.New;
end;

procedure TModelDatabase.CreateTables;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := FConnection.Connection;
    FDQuery.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS TASK (' +
      'ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'TITLE TEXT NOT NULL,' +
      'DESCRIPTION TEXT,' +
      'DATE TEXT NOT NULL,' +
      'START_TIME TEXT NOT NULL,' +
      'END_TIME TEXT NOT NULL,' +
      'COLOR TEXT NOT NULL);';
    FDQuery.ExecSQL;
  finally
    FDQuery.Free;
  end;
end;

procedure TModelDatabase.InitializeDatabase;
begin
  CreateTables;
end;

end.

