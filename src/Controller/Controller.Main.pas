unit Controller.Main;

interface

uses
  Controller.Interfaces,
  Helper.Calendar,
  Helper.HourBlocks,
  FMX.Controls,
  FMX.Layouts,
  FMX.Objects,
  System.UITypes,
  System.SysUtils,
  Model.Entity.TASK,
  Controller.Task,
  Controller.Generic,
  Controller.Users,
  Model.Entity.User;

type
  TMainController = class(TInterfacedObject, IController)
  private
    FFORMS : iControllerForms;
    FTASK: iControllerEntity<TTASK>;
    FCALENDAR : iControllerCalendar;
    FUtils : iControllerUtils;
    FUSER: iControllerUsers;
    FEntityUSER : iControllerEntity<TUser>;
    FCurrentUser : TCurrentUSER;
    constructor Create;
  public
    class function New: iController;
    function USER: iControllerUsers;
    function setCurrentUser(Value : TCurrentUSER) : iController;
    function CurrentUser : TCurrentUSER;
    function EntityUSER: iControllerEntity<TUser>;
    function CALENDAR: iControllerCalendar;
    function FORMS: iControllerForms;
    function TASK: iControllerEntity<TTASK>;
    function UTILS: iControllerUtils;
  end;

var
  Main: iController;

implementation

uses
  System.Types,
  Controller.Forms,
  Controller.Calendar,
  Controller.UTILS;

{ TMainController }

function TMainController.CALENDAR: iControllerCalendar;
begin
  if not Assigned(FCALENDAR) then
   FCALENDAR := TControllerCalendar.New(Self);

  Result := FCALENDAR;
end;

constructor TMainController.Create;
begin

end;

function TMainController.CurrentUser: TCurrentUSER;
begin
  Result := FCurrentUser;
end;

function TMainController.FORMS: iControllerForms;
begin
  if not Assigned(FFORMS) then
   FFORMS := TControllerForms.New(Self);

  Result := FFORMS;
end;

class function TMainController.New: iController;
begin
  Result := Self.Create;
end;

function TMainController.setCurrentUser(
  Value: TCurrentUSER): iController;
begin
  Result := self;
  FCurrentUser := value;
end;

function TMainController.TASK: iControllerEntity<TTASK>;
begin
   if not Assigned(FTASK) then
    FTASK := TControllerGeneric<TTASK>.New(Self);

   Result := FTASK;
end;

function TMainController.EntityUSER: iControllerEntity<TUser>;
begin
   if not Assigned(FEntityUSER) then
    FEntityUSER := TControllerGeneric<TUser>.New(Self);

   Result := FEntityUSER;
end;

function TMainController.USER: iControllerUsers;
begin
   if not Assigned(FUSER) then
    FUSER := TControllerUsers.New(Self);

   Result := FUSER;
end;

function TMainController.UTILS: iControllerUtils;
begin
   if not Assigned(FUtils) then
    FUtils := TControllerUtils.New(Self);

   Result := FUtils;
end;

initialization
  Main := TMainController.New;

end.

