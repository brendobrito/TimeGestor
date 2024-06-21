unit Controller.Task;

interface

uses
  Controller.Interfaces, Model.DAO.Interfaces, Model.Entity.Task;

type
  TControllerTask = class(TInterfacedObject, iControllerTask)
  private
    [weak]
    FParent: IController;
    FModel: iDAOGeneric<TTask>;
  public
    constructor Create(Parent: IController);
    destructor Destroy; override;
    class function New(Parent: IController): iControllerTask;
    function DAO: iDAOGeneric<TTask>;
    function &End: IController;
  end;

implementation

uses
  Model.DAO.Factory, Model.DAO.SQL;

{ TControllerTask }

constructor TControllerTask.Create(Parent: IController);
begin
  FParent := Parent;
  FModel :=  TModelDAOSQL<TTask>.New;
end;

function TControllerTask.DAO: iDAOGeneric<TTask>;
begin
  Result := FModel;
end;

destructor TControllerTask.Destroy;
begin
  inherited;
end;

class function TControllerTask.New(Parent: IController): iControllerTask;
begin
  Result := Self.Create(Parent);
end;

function TControllerTask.&End: IController;
begin
  Result := FParent;
end;

end.

