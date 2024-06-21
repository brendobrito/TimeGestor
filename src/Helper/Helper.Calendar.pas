unit Helper.Calendar;

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Objects, FMX.StdCtrls, FMX.Layouts, DateUtils, FMX.Types, Controller.Interfaces;

type
  TCalendarHelper = class(TInterfacedObject, IHelper)
  private
    FParent: TScrollBox;
    FStartDate: TDate;
    FEndDate: TDate;
    procedure CreateDayRectangle(AParent: TScrollBox; ADate: TDate; XPosition: Single);
    function CreateRectangle(AParent: TControl; XPosition: Single): TRectangle;
    function CreateCircle(AParent: TControl; ADate: TDate): TCircle;
    function CreateDayLabel(AParent: TControl; ADate: TDate): TLabel;
    function CreateDayDescLabel(AParent: TControl; ADate: TDate): TLabel;
    procedure ClearOldObjects;
  public
    constructor Create(AParent: TScrollBox);
    procedure Populate(AYear, AMonth: Integer);
  end;

implementation

uses
  FMX.Graphics, System.UITypes;

{ TCalendarHelper }

constructor TCalendarHelper.Create(AParent: TScrollBox);
begin
  FParent := AParent;
end;

procedure TCalendarHelper.ClearOldObjects;
begin
  FParent.BeginUpdate;
  try
    FParent.Content.DeleteChildren;
  finally
    FParent.EndUpdate;
  end;
end;

procedure TCalendarHelper.Populate(AYear, AMonth: Integer);
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
    CreateDayRectangle(FParent, CurrDate, XPosition);
    XPosition := XPosition + 129;
    CurrDate := CurrDate + 1;
  end;
end;

procedure TCalendarHelper.CreateDayRectangle(AParent: TScrollBox; ADate: TDate; XPosition: Single);
var
  Rect: TRectangle;
  Circle: TCircle;
begin
  Rect := CreateRectangle(AParent, XPosition);
  Circle := CreateCircle(Rect, ADate);
  CreateDayLabel(Circle, ADate);
  CreateDayDescLabel(Rect, ADate);
end;

function TCalendarHelper.CreateRectangle(AParent: TControl; XPosition: Single): TRectangle;
begin
  Result := TRectangle.Create(AParent);
  Result.Parent := AParent;
  Result.Align := TAlignLayout.None;
  Result.Width := 129;
  Result.Height := 97;
  Result.Position.X := XPosition;
  Result.Fill.Kind := TBrushKind.None;
  Result.Stroke.Kind := TBrushKind.None;
  Result.HitTest := False;
end;

function TCalendarHelper.CreateCircle(AParent: TControl; ADate: TDate): TCircle;
begin
  Result := TCircle.Create(AParent);
  Result.Parent := AParent;
  Result.Align := TAlignLayout.Bottom;
  Result.Width := 129;
  Result.Height := 50;
  if SameDate(ADate, Date) then
  begin
    Result.Fill.Color := $FF0386D6;
    Result.Stroke.Kind := TBrushKind.None;
  end
  else
  begin
    Result.Fill.Kind := TBrushKind.None;
    Result.Stroke.Kind := TBrushKind.None;
  end;
  Result.Margins.Bottom := 10;
  Result.HitTest := False;
end;

function TCalendarHelper.CreateDayLabel(AParent: TControl; ADate: TDate): TLabel;
begin
  Result := TLabel.Create(AParent);
  Result.Parent := AParent;
  Result.Align := TAlignLayout.Center;
  Result.AutoSize := True;
  Result.Text := IntToStr(DayOf(ADate));
  Result.TextSettings.Font.Size := 24;
  if SameDate(ADate, Date) then
    Result.TextSettings.FontColor := TAlphaColors.White
  else
    Result.TextSettings.FontColor := TAlphaColors.Black;
  Result.StyledSettings := [TStyledSetting.Family];
  Result.Visible := True;
  Result.WordWrap := False;
end;

function TCalendarHelper.CreateDayDescLabel(AParent: TControl; ADate: TDate): TLabel;
const
  DayNames: array[1..7] of string = ('DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB');
begin
  Result := TLabel.Create(AParent);
  Result.Parent := AParent;
  Result.Align := TAlignLayout.Bottom;
  Result.AutoSize := True;
  Result.Margins.Bottom := 3;
  Result.Text := DayNames[DayOfWeek(ADate)];
  Result.TextSettings.Font.Size := 14;

  if SameDate(ADate, Date) then
    Result.TextSettings.FontColor := $FF0386D6
  else
    Result.TextSettings.FontColor := TAlphaColors.Black;

  Result.TextSettings.HorzAlign := TTextAlign.Center;
  Result.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
end;

end.

