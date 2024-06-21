unit Helper.HourBlocks;

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Objects, FMX.Types, FMX.Graphics, Controller.Interfaces, FMX.Layouts,
  System.UITypes, Generics.Collections;

type
  TTaskRectangle = class(TRectangle)
  private
    FTaskID: string;
  public
    property TaskID: string read FTaskID write FTaskID;
  end;

  THourBlocksHelper = class(TInterfacedObject, IHourBlocks)
  private
    FParent: TScrollBox;
    FHoursRect: TRectangle;
    FStartDate: TDate;
    FEndDate: TDate;
    FTasks: TTaskList;
    FFirstTaskPosition: TTaskPosition;
    procedure CreateDayBlocks(ADate: TDate; XPosition: Single);
    function CreateBlockContainer(XPosition: Single): TRectangle;
    procedure CreateBlock(AParent: TRectangle; ATask: TTaskDetails; YPosition, BlockHeight: Single);
    procedure CreateHourLabels;
    procedure AdjustScrollBoxHeight;
    procedure ClearOldObjects;
    function HasTitleOrDescription(ATaskBlock: TRectangle): Boolean;
    procedure AddTitleAndDescription(ATaskBlock: TRectangle; const ATitle, ADescription: string; const StartTime, EndTime: TTime);
    procedure BlockDblClick(Sender: TObject);
  public
    constructor Create(AParent: TScrollBox; AHoursRect: TRectangle);
    destructor Destroy; override;
    procedure Populate(AYear, AMonth: Integer);
    procedure AddTask(ATask: TTaskDetails);
    procedure RemoveTask(TaskID: string);
  end;

implementation

uses
  FMX.StdCtrls, System.DateUtils, System.IOUtils, Controller.Main,
  System.Variants;

{ THourBlocksHelper }

constructor THourBlocksHelper.Create(AParent: TScrollBox; AHoursRect: TRectangle);
begin
  FParent := AParent;
  FHoursRect := AHoursRect;
  FTasks := TTaskList.Create;
  FFirstTaskPosition.X := -1;
  FFirstTaskPosition.Y := -1;
end;

destructor THourBlocksHelper.Destroy;
begin
  FTasks.Free;
  inherited;
end;

procedure THourBlocksHelper.ClearOldObjects;
var
  I: Integer;
begin
  if Assigned(FParent) then
  begin
    FParent.BeginUpdate;
    try
      for I := FParent.Content.ChildrenCount - 1 downto 0 do
      begin
        FParent.Content.RemoveObject(I);
      end;
    finally
      FParent.EndUpdate;
    end;
  end;

  if Assigned(FHoursRect) then
  begin
    FHoursRect.BeginUpdate;
    try
      for I := FHoursRect.ChildrenCount - 1 downto 0 do
      begin
        FHoursRect.RemoveObject(I);
      end;
    finally
      FHoursRect.EndUpdate;
    end;
  end;
end;

procedure THourBlocksHelper.Populate(AYear, AMonth: Integer);
var
  CurrDate: TDate;
  XPosition: Single;
begin
  ClearOldObjects;

  FStartDate := EncodeDate(AYear, AMonth, 1);
  FEndDate := EndOfTheMonth(FStartDate);

  XPosition := 0;
  CurrDate := FStartDate;

  while CurrDate <= FEndDate do
  begin
    CreateDayBlocks(CurrDate, XPosition);
    XPosition := XPosition + 129;
    CurrDate := CurrDate + 1;
  end;

  AdjustScrollBoxHeight;
  CreateHourLabels;
end;

procedure THourBlocksHelper.CreateDayBlocks(ADate: TDate; XPosition: Single);
var
  Container: TRectangle;
  i, TaskStartHour, TaskEndHour, HourIndex: Integer;
  Task: TTaskDetails;
  TaskExists: Boolean;
  YPosition, TaskStartMinHeight, TaskEndMinHeight, BlockHeight: Single;
begin
  Container := CreateBlockContainer(XPosition);

  HourIndex := 0;
  while HourIndex <= 23 do
  begin
    TaskExists := False;
    YPosition := HourIndex * 80;

    for i := 0 to FTasks.Count - 1 do
    begin
      Task := FTasks[i];
      if (DateToStr(Task.Date) = DateToStr(ADate)) then
      begin
        TaskStartHour := HourOf(Task.StartTime);
        TaskEndHour := HourOf(Task.EndTime);

        if (TaskStartHour = HourIndex) then
        begin
          TaskStartMinHeight := (MinuteOf(Task.StartTime) / 60) * 80;
          TaskEndMinHeight := (MinuteOf(Task.EndTime) / 60) * 80;
          BlockHeight := ((TaskEndHour - TaskStartHour) * 80) + TaskEndMinHeight - TaskStartMinHeight;

          // Criar bloco complementar antes da task
          if TaskStartMinHeight > 0 then
            CreateBlock(Container, Default(TTaskDetails), YPosition, TaskStartMinHeight);

          // Criar bloco da task
          CreateBlock(Container, Task, YPosition + TaskStartMinHeight, BlockHeight);

          // Definir posição da primeira task
          if (FFirstTaskPosition.X = -1) and (FFirstTaskPosition.Y = -1) then
          begin
            FFirstTaskPosition.X := XPosition;
            FFirstTaskPosition.Y := YPosition + TaskStartMinHeight;
          end;

          // Criar bloco complementar depois da task
          if (TaskEndMinHeight > 0) and (HourIndex + Trunc(BlockHeight / 80) < 23) then
            CreateBlock(Container, Default(TTaskDetails), YPosition + TaskStartMinHeight + BlockHeight, 80 - TaskEndMinHeight);

          HourIndex := TaskEndHour;

          if MinuteOf(Task.EndTime) > 0 then
            Inc(HourIndex);

          TaskExists := True;
          Break;
        end;
      end;
    end;

    if not TaskExists then
    begin
      CreateBlock(Container, Default(TTaskDetails), YPosition, 80);
      Inc(HourIndex);
    end;
  end;
end;

function THourBlocksHelper.CreateBlockContainer(XPosition: Single): TRectangle;
begin
  Result := TRectangle.Create(FParent);
  Result.Parent := FParent;
  Result.Align := TAlignLayout.None;
  Result.Width := 129;
  Result.Height := 24 * 80;
  Result.Position.X := XPosition;
  Result.Fill.Color := TAlphaColors.White;
  Result.Stroke.Kind := TBrushKind.None;
  Result.HitTest := False;
end;

function THourBlocksHelper.HasTitleOrDescription(ATaskBlock: TRectangle): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to ATaskBlock.ChildrenCount - 1 do
  begin
    if (ATaskBlock.Children[i] is TLabel) and
       ((TLabel(ATaskBlock.Children[i]).TextSettings.Font.Style = [TFontStyle.fsBold]) or
       (TLabel(ATaskBlock.Children[i]).Text <> '')) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure THourBlocksHelper.CreateBlock(AParent: TRectangle; ATask: TTaskDetails; YPosition, BlockHeight: Single);
var
  Block: TTaskRectangle;
begin
  Block := TTaskRectangle.Create(AParent);
  Block.Parent := AParent;
  Block.Align := TAlignLayout.None;
  Block.Position.Y := YPosition;
  Block.Width := 129;
  Block.Height := BlockHeight;
  Block.TaskID := ATask.ID;
  Block.HitTest := false;

  if ATask.Color <> TAlphaColors.Null then
  begin
    Block.Fill.Color := ATask.Color;
    Block.Stroke.Kind := TBrushKind.None;
    if not HasTitleOrDescription(Block) then
      AddTitleAndDescription(Block, ATask.Title, ATask.Description, ATask.StartTime, ATask.EndTime);
  end
  else
  begin
    Block.Fill.Kind := TBrushKind.None;
    Block.Sides := [TSide.Bottom, TSide.Right];
    Block.Stroke.Color := $FFEDEDED;
  end;

  if Block.TaskID <> '' then
  begin
    Block.HitTest := True;
    Block.OnDblClick := BlockDblClick;
  end;
end;

procedure THourBlocksHelper.AddTitleAndDescription(ATaskBlock: TRectangle; const ATitle, ADescription: string; const StartTime, EndTime: TTime);
var
  TitleLabel, DescriptionLabel, HourLabel: TLabel;
  TimeRange: string;
begin
  TimeRange := FormatDateTime('hh:nn', StartTime) + ' - ' + FormatDateTime('hh:nn', EndTime);

  if ADescription <> '' then
  begin
    DescriptionLabel := TLabel.Create(ATaskBlock);
    DescriptionLabel.Parent := ATaskBlock;
    DescriptionLabel.Align := TAlignLayout.Top;
    DescriptionLabel.Margins.Top := 2;
    DescriptionLabel.Margins.Left := 2;
    DescriptionLabel.AutoSize := true;
    DescriptionLabel.Text := ADescription;
    DescriptionLabel.TextSettings.Font.Size := 10;
    DescriptionLabel.TextSettings.FontColor := TAlphaColors.White;
    DescriptionLabel.TextSettings.HorzAlign := TTextAlign.Leading;
    DescriptionLabel.StyledSettings := [TStyledSetting.Family, TStyledSetting.Size];
    DescriptionLabel.WordWrap := true;
    DescriptionLabel.HitTest := False;
  end;

  if ATitle <> '' then
  begin
    TitleLabel := TLabel.Create(ATaskBlock);
    TitleLabel.AutoSize := true;
    TitleLabel.Parent := ATaskBlock;
    TitleLabel.Align := TAlignLayout.Top;
    TitleLabel.Margins.Top := 2;
    TitleLabel.Margins.Left := 5;
    TitleLabel.Margins.Right := 5;
    TitleLabel.Text := ATitle;
    TitleLabel.TextSettings.Font.Size := 12;
    TitleLabel.TextSettings.FontColor := TAlphaColors.White;
    TitleLabel.TextSettings.Font.Style := [TFontStyle.fsBold];
    TitleLabel.TextSettings.HorzAlign := TTextAlign.Center;
    TitleLabel.StyledSettings := [TStyledSetting.Family, TStyledSetting.Size];
    TitleLabel.HitTest := False;
  end;

  if ATitle <> '' then
  begin
    HourLabel := TLabel.Create(ATaskBlock);
    HourLabel.AutoSize := true;
    HourLabel.Parent := ATaskBlock;
    HourLabel.Align := TAlignLayout.Top;
    HourLabel.Margins.Top := 2;
    HourLabel.Margins.Left := 5;
    HourLabel.Margins.Right := 5;
    HourLabel.Text := ' ' + TimeRange + '';
    HourLabel.TextSettings.Font.Size := 10;
    HourLabel.TextSettings.FontColor := TAlphaColors.White;
    HourLabel.TextSettings.HorzAlign := TTextAlign.Center;
    HourLabel.StyledSettings := [TStyledSetting.Family, TStyledSetting.Size];
    HourLabel.HitTest := False;
  end;
end;

procedure THourBlocksHelper.CreateHourLabels;
var
  i: Integer;
  HourRect: TRectangle;
begin
  for i := 23 DownTo 0 do
  begin
    HourRect := TRectangle.Create(FHoursRect);
    HourRect.Parent := FHoursRect;
    HourRect.Height := 80;
    HourRect.Position.Y := 80 * i;
    HourRect.Fill.Kind := TBrushKind.None;
    HourRect.Stroke.Kind := TBrushKind.None;
    HourRect.HitTest := false;

    with TLabel.Create(HourRect) do
    begin
      Parent := HourRect;
      Align := TAlignLayout.Client;
      Text := Format('%.2d:00', [i]);
      TextSettings.Font.Size := 10;
      TextSettings.HorzAlign := TTextAlign.Center;
      TextSettings.VertAlign := TTextAlign.Leading;
      StyledSettings := [TStyledSetting.Family];
      AutoSize := False;
      HitTest := false;
    end;
  end;
end;

procedure THourBlocksHelper.AdjustScrollBoxHeight;
begin
  FParent.Height := 24 * 80;
  FHoursRect.Height := 24 * 80;
end;

procedure THourBlocksHelper.AddTask(ATask: TTaskDetails);
begin
  FTasks.Add(ATask);
  Populate(YearOf(ATask.Date), MonthOf(ATask.Date));
end;

procedure THourBlocksHelper.BlockDblClick(Sender: TObject);
var
  TaskBlock: TTaskRectangle;
begin
  if Sender is TTaskRectangle then
  begin
    TaskBlock := TTaskRectangle(Sender);
    Main.FORMS.TaskManager(TaskBlock.TaskID);
  end;
end;

procedure THourBlocksHelper.RemoveTask(TaskID: string);
var
  i: Integer;
  sid : string;
  Block: TTaskRectangle;
begin
  FParent.BeginUpdate;
  try
    for i := FParent.Content.ChildrenCount - 1 downto 0 do
    begin
      if FParent.Content.Children[i] is TTaskRectangle then
      begin
        Block := TTaskRectangle(FParent.Content.Children[i]);
        if Block.TaskID = TaskID then
        begin
          FParent.Content.RemoveObject(i);
          Block.DisposeOf;
        end;
      end;
    end;
  finally
    FParent.EndUpdate;
  end;

  for i := FTasks.Count - 1 downto 0 do
  begin
    try
      sid := FTasks[i].ID;
    except
     continue;
    end;

    if (FTasks[i].ID = TaskID) then
    begin
      FTasks.Delete(i);
      Break;
    end;
  end;
end;

end.

