unit Controller.Generic;

interface

uses
  Controller.Interfaces,
  Model.DAO.Interfaces;

type
  TControllerGeneric<T : class, constructor> = class(TInterfacedObject, iControllerEntity<T>)
    private
      [weak]
      FParent : iController;
      FModel : iDAOGeneric<T>;
    public
      constructor Create(Parent : iController);
      destructor Destroy; override;
      class function New(Parent : iController) : iControllerEntity<T>;
      function DAO : iDAOGeneric<T>;
      function &End : iController;
  end;

implementation

uses
  Model.DAO.Factory;

{ TControllerGeneric }

function TControllerGeneric<T>.&End: iController;
begin
  Result := FParent;
end;

constructor TControllerGeneric<T>.Create(Parent : iController);
begin
  FParent := Parent;
  FModel := TModelDAOFactory<T>.New.DAO;
end;

function TControllerGeneric<T>.DAO: iDAOGeneric<T>;
begin
  Result := FModel;
end;

destructor TControllerGeneric<T>.Destroy;
begin

  inherited;
end;

class function TControllerGeneric<T>.New(Parent : iController): iControllerEntity<T>;
begin
  Result := Self.Create(Parent);
end;

end.
