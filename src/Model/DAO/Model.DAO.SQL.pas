unit Model.DAO.SQL;

interface

uses
  Datasnap.DBClient,
  System.Rtti,
  Data.DB,
  SimpleInterface,
  SimpleDAO,
  SimpleAttributes,
  SimpleQueryFiredac,
  Model.DAO.Interfaces,
  System.Generics.Collections,
  System.SysUtils,
  Model.Connection.Interfaces,
  FireDAC.Comp.Client,
  System.TypInfo;

type
  TModelDAOSQL<T : class,constructor> = class(TInterfacedObject, iDAOGeneric<T>)
  private
    FConn: iSimpleQuery;
    FDAO: iSimpleDAO<T>;
    FDataSource: TDataSource;
    FObject: T;
    FConnectionInstance: iConnection<TFDConnection>;

  public
    constructor Create;
    destructor Destroy; override;
    class function New: iDAOGeneric<T>;
    function Insert: iDAOGeneric<T>;
    function Update: iDAOGeneric<T>;
    function ListToDataSet(List: TObjectList<T>): TDataSet;
    function Find: iDAOGeneric<T>; overload;
    function Find(const aID: String): iDAOGeneric<T>; overload;
    function Find(var aList: TObjectList<T>): iDAOGeneric<T>; overload;
    function Find(aParam: String; aValue: String): iDAOGeneric<T>; overload;
    function FindWithConditions(const SQLConditions: String): TObjectList<T>;
    function Delete: iDAOGeneric<T>; overload;
    function Delete(aParam: String; aValue: String): iDAOGeneric<T>; overload;
    function DataSource(aValue: TDataSource): iDAOGeneric<T>;
    function Current: T;
    function NewObject: T;
    function DataSet: TDataSet;
    function LastID: Integer;
    function SQL: iSimpleDAOSQLAttribute<T>;

  end;

implementation

uses
  Model.Connection.SQLite;

{ TModelDAOSQL<T> }

function TModelDAOSQL<T>.SQL: iSimpleDAOSQLAttribute<T>;
begin
  Result := FDAO.SQL;
end;

function TModelDAOSQL<T>.ListToDataSet(List: TObjectList<T>): TDataSet;
var
  CDS: TClientDataSet;
  RTTIContext: TRttiContext;
  RTTIType: TRttiType;
  Prop: TRttiProperty;
  FieldDef: TFieldDef;
begin
  CDS := TClientDataSet.Create(nil);
  try
    RTTIType := RTTIContext.GetType(TClass(T));
    CDS.FieldDefs.Clear;

    for Prop in RTTIType.GetProperties do
      if Prop.Visibility = mvPublished then
      begin
        FieldDef := CDS.FieldDefs.AddFieldDef;
        FieldDef.Name := Prop.Name;
        if Prop.PropertyType.TypeKind = tkFloat then
        begin
          if Prop.PropertyType.Handle = TypeInfo(TDate) then
            FieldDef.DataType := ftDate
          else if Prop.PropertyType.Handle = TypeInfo(TDateTime) then
            FieldDef.DataType := ftDateTime
          else if Prop.Name = 'Time' then
            FieldDef.DataType := ftTime
          else
            FieldDef.DataType := ftFloat;
        end
        else if Prop.PropertyType.TypeKind = tkInteger then
          FieldDef.DataType := ftInteger
        else if (Prop.PropertyType.TypeKind = tkString) or (Prop.PropertyType.TypeKind = tkUString) then
        begin
          FieldDef.DataType := ftWideString;
          FieldDef.Size := 255;
        end
        else if Prop.PropertyType.TypeKind = tkEnumeration then
          if Prop.PropertyType.Handle = TypeInfo(Boolean) then
            FieldDef.DataType := ftBoolean;
      end;

    CDS.CreateDataSet;
    CDS.Open;
    for var Item in List do
    begin
      CDS.Append;
      for Prop in RTTIType.GetProperties do
        if Prop.Visibility = mvPublished then
        begin
          var Value: TValue := Prop.GetValue(TObject(Item));
          CDS.FieldByName(Prop.Name).Value := Value.AsVariant;
        end;
      CDS.Post;
    end;

    Result := CDS;
  except
    CDS.Free;
    raise;
  end;
end;


function TModelDAOSQL<T>.FindWithConditions(const SQLConditions: String): TObjectList<T>;
begin
  Result := TObjectList<T>.Create;
  FDAO.SQL.Where(SQLConditions).&End.Find(Result);
end;

constructor TModelDAOSQL<T>.Create;
begin
  FDataSource := TDataSource.Create(nil);
  FConnectionInstance := TModelConnectionSQLite.New;
  FConn := TSimpleQueryFiredac.New(FConnectionInstance.Connection);
  FDAO := TSimpleDAO<T>.New(FConn).DataSource(FDataSource);
end;

function TModelDAOSQL<T>.Current: T;
begin
  Result := FDAO.Current;
end;

function TModelDAOSQL<T>.DataSet: TDataSet;
begin
  Result := FDataSource.DataSet;
end;

function TModelDAOSQL<T>.DataSource(aValue: TDataSource): iDAOGeneric<T>;
begin
  Result := Self;
  aValue.DataSet := FDataSource.DataSet;
end;

function TModelDAOSQL<T>.Delete: iDAOGeneric<T>;
begin
  Result := Self;
  FDAO.Delete(FObject);
end;

function TModelDAOSQL<T>.Delete(aParam, aValue: String): iDAOGeneric<T>;
begin
  Result := Self;

  if UPPERCASE(aParam) = 'ID' then
    aValue := QuotedStr(aValue);

  FDAO.Delete(aParam, aValue);
end;

destructor TModelDAOSQL<T>.Destroy;
begin
  FDataSource.Free;

  if Assigned(FObject) then
    FObject.Free;

  inherited;
end;

function TModelDAOSQL<T>.Find(aParam, aValue: String): iDAOGeneric<T>;
begin
  Result := Self;

  if UPPERCASE(aParam) = 'ID' then
    aValue := QuotedStr(aValue);

  FDAO.SQL.Where(aParam + ' = ' + aValue).&End.Find;
end;

function TModelDAOSQL<T>.Find(var aList: TObjectList<T>): iDAOGeneric<T>;
begin
  Result := Self;
  FDAO.Find(aList);
end;

function TModelDAOSQL<T>.Find(const aID: String): iDAOGeneric<T>;
begin
  Result := Self;
  if Assigned(FObject) then
    FObject.Free;

  FObject := FDAO.Find(StrToInt(aId));
end;

function TModelDAOSQL<T>.Find: iDAOGeneric<T>;
begin
  Result := Self;
  FDAO.Find;
end;

function TModelDAOSQL<T>.Insert: iDAOGeneric<T>;
begin
  Result := Self;
  FDAO.Insert(FObject);
end;

function TModelDAOSQL<T>.LastID: Integer;
begin
  FDAO.LastID;
  Result := FDataSource.DataSet.FieldByName('ID').AsInteger;
end;

class function TModelDAOSQL<T>.New: iDAOGeneric<T>;
begin
  Result := Self.Create;
end;

function TModelDAOSQL<T>.NewObject: T;
begin
  if Assigned(FObject) then
    FObject.Free;

  FObject := T.Create;
  Result := FObject;
end;

function TModelDAOSQL<T>.Update: iDAOGeneric<T>;
begin
  Result := Self;
  FDAO.Update(FObject);
end;

end.

