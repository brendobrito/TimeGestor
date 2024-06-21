unit Controller.Calendar;

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
  Model.Entity.Task,
  Model.DAO.Interfaces,
  System.Types, Data.DB, System.Generics.Defaults;

type
  TControllerCalendar = class(TInterfacedObject, IControllerCalendar)
  private
    FCalendarHelper: IHelper;
    FHourBlocksHelper: IHourBlocks;
    FHourBlocksParent: TScrollBox;
    FCalendarParent: TScrollBox;
    FYear: Integer;
    FMonth: Integer;
    FParent: iController;
    FTaskDAO: iDAOGeneric<TTask>;
    FHoursRect: TRectangle;
    FLastPosScroll : TTaskPosition;
    FDS_SortedTasks: TDataSource;
    FDS_OverdueTasks : TDataSource;
    FOnLoadDatabase : TProc;
    FOnAfterPopulate : TProc<integer, integer>;
    constructor Create(AParent: iController);
  public
    class function New(AParent: iController): IControllerCalendar;
    function &End: IController;
    function Initialize(ACalendarParent, AHourBlocksParent: TScrollBox; AHoursRect: TRectangle): IControllerCalendar;
    function RenderTask(ATask: TTaskDetails; ScrollToTask : boolean = false): IControllerCalendar;
    function SaveTask(ATask: TTask; ScrollToTask: boolean = false): IControllerCalendar;
    function RemoveTask(ATaskID: string): IControllerCalendar;
    function Populate(AYear, AMonth: Integer): IControllerCalendar;
    function LoadTasksFromDatabase(AYear, AMonth: Integer): IControllerCalendar;
    function LoadSortedTasks(DataSource: TDataSource): IControllerCalendar;
    function LoadOverdueTasks(DataSource: TDataSource): IControllerCalendar;

    function GetTaskPosition(TaskID: string): TTaskPosition;
    function ScrollToFirstTask: IControllerCalendar;
    function ScrollToPos(ATaskPos: TTaskPosition): IControllerCalendar;
    function ScrollToStandardPosition: IControllerCalendar;
    function AfterLoadDatabase(AEvent : TProc) : IControllerCalendar;
    function AfterPopulate(AEvent : TProc<integer, integer>) : IControllerCalendar;
  end;

implementation

uses
  Controller.Forms, Model.DAO.Factory,
  System.Generics.Collections, System.DateUtils, System.UIConsts;

{ TControllerCalendar }

function TControllerCalendar.LoadSortedTasks(DataSource: TDataSource): IControllerCalendar;
var
  TaskList: TObjectList<TTask>;
  FilteredTasks: TObjectList<TTask>;
  DataSet: TDataSet;
  Field: TField;
  CurrentDateTime, TaskEndDateTime, TempTime: TDateTime;
begin
  Result := self;

  if not Assigned(DataSource) or not Assigned(FTaskDAO) then
    Exit;

  FDS_SortedTasks := DataSource;
  CurrentDateTime := Now;

  TaskList := TObjectList<TTask>.Create(True);
  FilteredTasks := TObjectList<TTask>.Create(True);
  try
    FTaskDAO.SQL.Clear
    .Where(Format('USERID = %s', [QuotedStr(FParent.CurrentUser.ID)]))
    .&End
    .Find(TaskList);

    for var Task in TaskList do
    begin
      if TryStrToTime(Task.EndTime, TempTime) then
      begin
        TaskEndDateTime := EncodeDateTime(YearOf(Task.Date), MonthOf(Task.Date), DayOf(Task.Date),
                                          HourOf(TempTime), MinuteOf(TempTime), SecondOf(TempTime), 0);
        if (TaskEndDateTime > CurrentDateTime) and ((Task.IsCompleted <> '0') and (Task.IsCompleted <> 'True')) then
          FilteredTasks.Add(Task.Clone as TTask);
      end;
    end;

    FilteredTasks.Sort(TComparer<TTask>.Construct(function(const L, R: TTask): Integer
    begin
      Result := CompareDate(L.Date, R.Date);
      if Result = 0 then
        Result := CompareTime(StrToTime(L.StartTime), StrToTime(R.StartTime));
    end));

    DataSet := FTaskDAO.ListToDataSet(FilteredTasks);

    for Field in DataSet.Fields do
    begin
      if Field.FieldName = 'ID' then
        Field.Visible := False
      else if Field.FieldName = 'Title' then
        Field.Visible := True
      else if Field.FieldName = 'Date' then
        Field.Visible := True
      else if Field.FieldName = 'StartTime' then
        Field.Visible := True
      else if Field.FieldName = 'EndTime' then
        Field.Visible := True
      else
        Field.Visible := False;
    end;

    DataSource.DataSet := DataSet;

  //  if Assigned(FOnLoadDatabase) then
  //    FOnLoadDatabase;
  finally
    TaskList.Free;
    FilteredTasks.Free;
  end;
end;

function TControllerCalendar.LoadOverdueTasks(DataSource: TDataSource): IControllerCalendar;
var
  TaskList: TObjectList<TTask>;
  OverdueTasks: TObjectList<TTask>;
  DataSet: TDataSet;
  Field: TField;
  CurrentDateTime, TaskEndDateTime, TempTime: TDateTime;
begin
  Result := self;

  if not Assigned(DataSource) or not Assigned(FTaskDAO) then
    Exit;

  FDS_OverdueTasks := DataSource;
  CurrentDateTime := Now;

  TaskList := TObjectList<TTask>.Create(True);
  OverdueTasks := TObjectList<TTask>.Create(True);
  try
    FTaskDAO.SQL.Clear
    .Where(Format('USERID = %s', [QuotedStr(FParent.CurrentUser.ID)]))
    .&End
    .Find(TaskList);

    for var Task in TaskList do
    begin
      if TryStrToTime(Task.EndTime, TempTime) then
      begin
        TaskEndDateTime := EncodeDateTime(YearOf(Task.Date), MonthOf(Task.Date), DayOf(Task.Date),
                                          HourOf(TempTime), MinuteOf(TempTime), SecondOf(TempTime), 0);
        if (TaskEndDateTime < CurrentDateTime) and ((Task.IsCompleted <> '0') and (Task.IsCompleted <> 'True'))  then
          OverdueTasks.Add(Task.Clone as TTask);
      end;
    end;

    OverdueTasks.Sort(TComparer<TTask>.Construct(function(const L, R: TTask): Integer
    begin
      Result := CompareDate(R.Date, L.Date);
      if Result = 0 then
        Result := CompareTime(StrToTime(R.StartTime), StrToTime(L.StartTime));
    end));

    DataSet := FTaskDAO.ListToDataSet(OverdueTasks);

    for Field in DataSet.Fields do
    begin
      if Field.FieldName = 'ID' then
        Field.Visible := False
      else if Field.FieldName = 'Title' then
        Field.Visible := True
      else if Field.FieldName = 'Date' then
        Field.Visible := True
      else if Field.FieldName = 'StartTime' then
        Field.Visible := True
      else if Field.FieldName = 'EndTime' then
        Field.Visible := True
      else
        Field.Visible := False;
    end;

    DataSource.DataSet := DataSet;

    if Assigned(FOnLoadDatabase) then
      FOnLoadDatabase;
  finally
    TaskList.Free;
    OverdueTasks.Free;
  end;
end;

function TControllerCalendar.AfterLoadDatabase(
  AEvent: TProc): IControllerCalendar;
begin
  Result := self;
  FOnLoadDatabase := AEvent;
end;

function TControllerCalendar.AfterPopulate(AEvent: TProc<integer, integer>): IControllerCalendar;
begin
  Result := self;
  FOnAfterPopulate := AEvent;
end;

constructor TControllerCalendar.Create(AParent: iController);
begin
  FParent := AParent;
  FTaskDAO := TModelDAOFactory<TTask>.New.DAO;
end;

class function TControllerCalendar.New(AParent: iController): IControllerCalendar;
begin
  Result := Self.Create(AParent);
end;

function TControllerCalendar.Initialize(ACalendarParent, AHourBlocksParent: TScrollBox; AHoursRect: TRectangle): IControllerCalendar;
begin
  Result := Self;

  FCalendarHelper := TCalendarHelper.Create(ACalendarParent);
  FHourBlocksHelper := THourBlocksHelper.Create(AHourBlocksParent, AHoursRect);

  FHoursRect := AHoursRect;
  FHourBlocksParent := AHourBlocksParent;
  FCalendarParent := ACalendarParent;
end;

function TControllerCalendar.Populate(AYear, AMonth: Integer): IControllerCalendar;
begin
  Result := Self;

  if (FYear <> AYear) or (FMonth <> AMonth) then
  begin
    FYear := AYear;
    FMonth := AMonth;

    Initialize(FCalendarParent, FHourBlocksParent, FHoursRect);
    LoadTasksFromDatabase(FYear, FMonth);
  end;

  FYear := AYear;
  FMonth := AMonth;

  FCalendarHelper.Populate(AYear, AMonth);
  FHourBlocksHelper.Populate(AYear, AMonth);

  if Assigned(FOnAfterPopulate) then
    FOnAfterPopulate(AMonth, AYear);
end;

function TControllerCalendar.RemoveTask(ATaskID: string): IControllerCalendar;
begin
  Result := self;

   FParent.TASK.DAO.SQL.Clear
    .Where(Format('USERID = %s ', [QuotedStr(FParent.CurrentUser.ID)]))
    .&End
    .Delete('ID', QuotedStr(ATaskID));

  FHourBlocksHelper.RemoveTask(ATaskID);

  Initialize(FCalendarParent, FHourBlocksParent, FHoursRect);
  LoadTasksFromDatabase(FYear, FMonth);
  LoadSortedTasks(FDS_SortedTasks);
  LoadOverdueTasks(FDS_OverdueTasks);

  //Mantém a posição
  ScrollToPos(FLastPosScroll);
end;

function TControllerCalendar.LoadTasksFromDatabase(AYear, AMonth: Integer): IControllerCalendar;
var
  TaskDetails: TTaskDetails;
  TaskList: TObjectList<TTask>;
  Task: TTask;
begin
  Result := Self;

  if not Assigned(FHourBlocksHelper) then
    Exit;

  TaskList := TObjectList<TTask>.Create;
  try
    FParent.TASK.DAO.SQL.Clear
      .Where(Format('USERID = %s', [QuotedStr(FParent.CurrentUser.ID)]))
      .&End
      .Find(TaskList);

    for Task in TaskList do
    begin
      if (YearOf(Task.Date) = AYear) and (MonthOf(Task.Date) = AMonth) then
      begin
        TaskDetails.ID := Task.ID;
        TaskDetails.Date := Task.Date;
        TaskDetails.StartTime := StrToTime(Task.StartTime);
        TaskDetails.EndTime := StrToTime(Task.EndTime);
        TaskDetails.Color := StringToAlphaColor(Task.Color);
        TaskDetails.Title := Task.Title;
        TaskDetails.Description := Task.Description;
        RenderTask(TaskDetails);
      end;
    end;
  finally
    TaskList.Free;
  end;

  Populate(AYear, AMonth);
end;

function TControllerCalendar.&End: IController;
begin
  Result := FParent;
end;

function TControllerCalendar.SaveTask(ATask: TTask;
  ScrollToTask: boolean = false): IControllerCalendar;
  var
  sID :string;
  sInsert : boolean;
begin
  Result := self;
  sInsert := false;

  FLastPosScroll.X := FHourBlocksParent.ViewportPosition.X;
  FLastPosScroll.Y := FHourBlocksParent.ViewportPosition.Y;

  try
    ATask.USERID := FParent.CurrentUser.ID;

    if ATask.ID = '' then begin
      sInsert := true;
      ATask.ID := FParent.UTILS.NewUID;
      FParent.TASK.DAO.Insert;
    end else begin
      FParent.TASK.DAO.Update;
      Initialize(FCalendarParent, FHourBlocksParent, FHoursRect);
    end;

    sID := ATask.ID;
    LoadTasksFromDatabase(FYear, FMonth);

    if (ScrollToTask) and (sInsert) then
      ScrollToPos(GetTaskPosition(sID))
    else
      ScrollToPos(FLastPosScroll);

    LoadSortedTasks(FDS_SortedTasks);
    LoadOverdueTasks(FDS_OverdueTasks);

  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;

function TControllerCalendar.RenderTask(ATask: TTaskDetails; ScrollToTask : boolean = false): IControllerCalendar;
begin
  Result := Self;
  FHourBlocksHelper.AddTask(ATask);

  if ScrollToTask then
    ScrollToPos(GetTaskPosition(ATask.ID));
end;

function TControllerCalendar.ScrollToFirstTask: IControllerCalendar;
var
  TaskList: TObjectList<TTask>;
  TaskPos: TTaskPosition;
  SQLCondition: String;
  Task: TTask;
  CurrentDateTime, StartOfDay: TDateTime;
begin
  Result := Self;
  CurrentDateTime := Now;

  if (FYear = YearOf(CurrentDateTime)) and (FMonth = MonthOf(CurrentDateTime)) then
  begin
    ScrollToStandardPosition;
    exit;
  end
  else
  begin
    StartOfDay := EncodeDate(FYear, FMonth, 1);
    SQLCondition := Format('Date >= ''%s'' AND Date < ''%d-%.2d-%.2d 00:00:00'' ORDER BY Date, StartTime',
                           [FormatDateTime('yyyy-mm-dd hh:nn:ss', StartOfDay), FYear, FMonth + 1, 1]);
  end;
  TaskList := TObjectList<TTask>.Create;

  FParent.TASK.DAO.SQL.Clear.Where(SQLCondition).&End.Find(TaskList);

  if TaskList.Count > 0 then
  begin
    Task := TaskList.First;
    TaskPos.X := (DayOf(Task.Date) - 1) * 129;
    TaskPos.Y := HourOf(StrToTime(Task.StartTime)) * 80 + (MinuteOf(StrToTime(Task.StartTime)) * 80 div 60);

    ScrollToPos(TaskPos);
  end;

  TaskList.Free;
end;

function TControllerCalendar.ScrollToPos(ATaskPos: TTaskPosition): IControllerCalendar;
var
  DefaultDate: TDate;
begin
  Result := Self;

  DefaultDate := EncodeDate(1899, 12, 30);
  if (ATaskPos.X >= 0) and (ATaskPos.Y >= 0) then
  begin
    if (ATaskPos.Date <> DefaultDate) and
       ((YearOf(ATaskPos.Date) <> FYear) or (MonthOf(ATaskPos.Date) <> FMonth)) then
    begin
      Populate(YearOf(ATaskPos.Date), MonthOf(ATaskPos.Date));
    end;

    FHourBlocksParent.ViewportPosition := PointF(ATaskPos.X, ATaskPos.Y);
    FCalendarParent.ViewportPosition := PointF(ATaskPos.X, ATaskPos.Y);
    FLastPosScroll := ATaskPos;
  end;
end;

function TControllerCalendar.ScrollToStandardPosition: IControllerCalendar;
var
  CurrentDate: TDate;
  CurrentTime: TTime;
  CurrentHour, CurrentMinute, CurrentSecond, CurrentMilliSecond: Word;
  ScrollPositionY, ScrollPositionX: Integer;
  TaskPos: TTaskPosition;
begin
  Result := Self;

  CurrentTime := Time;
  CurrentDate := Date;
  DecodeTime(CurrentTime, CurrentHour, CurrentMinute, CurrentSecond, CurrentMilliSecond);

  ScrollPositionY := (CurrentHour * 80) - (2 * 80);
  if ScrollPositionY < 0 then
    ScrollPositionY := 0;

  ScrollPositionX := (DayOf(CurrentDate)-2) * 129;

  TaskPos.X := ScrollPositionX;
  TaskPos.Y := ScrollPositionY;
  TaskPos.Date := EncodeDate(FYear, FMonth, 1);
  ScrollToPos(TaskPos);
end;

function TControllerCalendar.GetTaskPosition(TaskID: string): TTaskPosition;
var
  Task: TTask;
  TaskDate: TDate;
  TaskStartHour: Word;
  TaskStartMinute: Word;
  TaskStartSecond: Word;
  TaskStartMilliSecond: Word;
begin
  Result.X := -1;
  Result.Y := -1;
  Result.Date := 0;

  Task := FParent.TASK.DAO.SQL.Clear
    .Where(Format('USERID = %s AND ID = %s', [QuotedStr(FParent.CurrentUser.ID), QuotedStr(TaskID)]))
    .&End.Find.Current;

  if Assigned(Task) then
  begin
    TaskDate := Task.Date;
    DecodeTime(StrToTime(Task.StartTime), TaskStartHour, TaskStartMinute, TaskStartSecond, TaskStartMilliSecond);

    Result.X := (DayOf(TaskDate) - 2) * 129;
    Result.Y := (TaskStartHour * 80) - (2 * 80);
    Result.Date := TaskDate;
  end;
end;


end.

