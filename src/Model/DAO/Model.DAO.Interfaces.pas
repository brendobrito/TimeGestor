unit Model.DAO.Interfaces;

interface

uses
  Data.DB, System.Generics.Collections, SimpleInterface, System.SysUtils;

type

  iDAOGeneric<T : class> = interface
    ['{8A78EC8B-7304-4FBA-9873-E1E25F5D3D01}']
    function Insert : iDAOGeneric<T>;
    function Update : iDAOGeneric<T>;
    function ListToDataSet(List: TObjectList<T>): TDataSet;
    function Find : iDAOGeneric<T>; overload;
    function Find (const aID : String ) : iDAOGeneric<T>; overload;
    function Find (var aList : TObjectList<T>) : iDAOGeneric<T> ; overload;
    function Find ( aParam : String; aValue : String) : iDAOGeneric<T>; overload;
    function FindWithConditions(const SQLConditions: String): TObjectList<T>;
    function Delete : iDAOGeneric<T>; overload;
    function Delete ( aParam : String; aValue : String) : iDAOGeneric<T>; overload;
    function DataSource ( aValue : TDataSource ) : iDAOGeneric<T>;
    function Current : T;
    function NewObject : T;
    function DataSet : TDataSet;
    function LastID : Integer;
    function SQL: iSimpleDAOSQLAttribute<T>;

  end;

  iDAOFactory<T : class> = interface
    ['{93AF4138-4CED-47CE-89C5-5001EB681FB0}']
    function DAO : iDAOGeneric<T>;
  end;

implementation

end.
