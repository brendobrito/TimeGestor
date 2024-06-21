unit Controller.Interfaces;

interface

uses
  System.UITypes, System.Generics.Collections, Model.Entity.TASK,
  Model.DAO.Interfaces, FMX.Layouts, FMX.Objects, Data.DB, System.SysUtils,
  Model.Entity.User;

type
  TCurrentUSER = record
    ID : string;
    Name : string;
    Email : string;
  end;

  TCredenciais = record
    Email: string;
    Senha: string;
    Lembrar: Boolean;
  end;

  TTaskDetails = record
    ID: string;
    Date: TDate;
    StartTime, EndTime: TTime;
    Color: TAlphaColor;
    Title: string;
    Description: string;
  end;

  TTaskPosition = record
    Date: TDate;
    X: Single;
    Y: Single;
  end;

  TTaskList = TList<TTaskDetails>;
  TDialogMessageType = (dmError, dmSuccess, dmInformation);

  IControllerCalendar = interface;
  iControllerTask = interface;
  iControllerForms = interface;
  iControllerEntity<T: class> = interface;
  iControllerUtils = interface;
  iControllerUsers = interface;

  IController = interface
    ['{B1F3A1D8-2A6A-4B62-BB8C-6B5E90B7314D}']
    function CurrentUser : TCurrentUSER;
    function setCurrentUser(Value : TCurrentUSER) : iController;
    function EntityUSER: iControllerEntity<TUser>;
    function USER: iControllerUsers;
    function CALENDAR: iControllerCalendar;
    function FORMS: iControllerForms;
    function TASK: iControllerEntity<TTASK>;
    function UTILS: iControllerUtils;
  end;

  iControllerUsers = interface
  ['{2A59D9A0-0E78-4A9C-99CA-8A1918594D8D}']
    function &End: IController;
    function SenhaValida(Pass1, Pass2: string): boolean;
    function ExisteValorNoCampo(const Campo, Valor: string): boolean;
    function Login(const Email, Password: string): Boolean;
    function NewUser(AUser: TUSER): iControllerUsers;
    function DAO: iDAOGeneric<TUSER>;
  end;

  iControllerUtils = interface
    ['{417FE11D-373D-4CD2-A183-C0C5A65F5A6C}']
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

  IControllerCalendar = interface
    ['{F16D13DE-6B43-413C-BA36-592339FAAF72}']
    function &End: IController;
    function Initialize(ACalendarParent, AHourBlocksParent: TScrollBox; AHoursRect: TRectangle): IControllerCalendar;
    function RenderTask(ATask: TTaskDetails; ScrollToTask : boolean = false): IControllerCalendar;
    function SaveTask(ATask: TTask; ScrollToTask: boolean = false): IControllerCalendar;
    function RemoveTask(ATaskID: string): IControllerCalendar;
    function Populate(AYear, AMonth: Integer): IControllerCalendar;
    function LoadTasksFromDatabase(AYear, AMonth: Integer): IControllerCalendar;
    function GetTaskPosition(TaskID: string): TTaskPosition;
    function LoadSortedTasks(DataSource: TDataSource): IControllerCalendar;
    function LoadOverdueTasks(DataSource: TDataSource): IControllerCalendar;
    function ScrollToFirstTask: IControllerCalendar;
    function ScrollToStandardPosition: IControllerCalendar;
    function ScrollToPos(ATaskPos: TTaskPosition): IControllerCalendar;
    function AfterLoadDatabase(AEvent : TProc) : IControllerCalendar;
    function AfterPopulate(AEvent : TProc<integer, integer>) : IControllerCalendar;
  end;

  IHelper = interface
    ['{D3A6A1E0-3A4A-40E9-BBE6-8B4F36E7314E}']
    procedure Populate(AYear, AMonth: Integer);
  end;

  IHourBlocks = interface
    ['{A3874BDC-E935-473A-926F-0482D5CD28A4}']
    procedure Populate(AYear, AMonth: Integer);
    procedure AddTask(ATask: TTaskDetails);
    procedure RemoveTask(TaskID: string);
  end;

  iControllerEntity<T: class> = interface
    ['{93AF4138-4CED-47CE-89C5-5001EB681FB0}']
    function DAO: iDAOGeneric<T>;
    function &End: IController;
  end;

  iControllerTask = interface(iControllerEntity<TTask>)
    ['{B9303A35-1095-4F27-B37D-A3E29A1E83DC}']
  end;

  iControllerForms = interface
    ['{2D4BD40E-475A-4B0E-A611-8B3E3D12E895}']
    function DialogMessage(aTitle,aDescription : string; aType : TDialogMessageType) : iControllerForms;
    function TaskManager(aTaskId : string = ''): iControllerForms;
    function Infos: iControllerForms;
  end;

implementation

end.

