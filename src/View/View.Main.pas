unit View.Main;

interface

uses
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  Helper.Calendar,
  Helper.HourBlocks,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Controls.Presentation,
  Controller.Interfaces,
  Controller.Main,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  View.TaskManager,
  System.Rtti,
  FMX.Grid.Style,
  FMX.Grid,
  Data.DB, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope;
type
  TfrmMain = class(TForm)
    lytCalendario: TLayout;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    RectHours: TRectangle;
    ScrollBox3: TScrollBox;
    Rectangle2: TRectangle;
    lbBoasVindas: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Rectangle4: TRectangle;
    lbMonth: TLabel;
    BtnLeft: TSpeedButton;
    BtnRight: TSpeedButton;
    Label6: TLabel;
    lbYear: TLabel;
    Layout7: TLayout;
    Rectangle5: TRectangle;
    Label5: TLabel;
    Rectangle6: TRectangle;
    Rectangle7: TRectangle;
    Rectangle8: TRectangle;
    Layout8: TLayout;
    Image3: TImage;
    Layout9: TLayout;
    lbCurrentemail: TLabel;
    lbCurrentUser: TLabel;
    Label4: TLabel;
    Layout10: TLayout;
    StyleBook1: TStyleBook;
    DataSource1: TDataSource;
    Grid1: TGrid;
    Grid2: TGrid;
    DataSource2: TDataSource;
    Label7: TLabel;
    SpeedButton1: TSpeedButton;
    Layout1: TLayout;
    Label9: TLabel;
    Label10: TLabel;
    Label1: TLabel;
    Label8: TLabel;
    Layout3: TLayout;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ScrollBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ScrollBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure ScrollBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ScrollBox1ViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
    procedure BtnRightClick(Sender: TObject);
    procedure BtnLeftClick(Sender: TObject);
    procedure Rectangle5Click(Sender: TObject);
    procedure ScrollBox2ViewportPositionChange(Sender: TObject;
      const OldViewportPosition, NewViewportPosition: TPointF;
      const ContentSizeChanged: Boolean);
    procedure Grid1GetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure Grid2CellDblClick(const Column: TColumn; const Row: Integer);
    procedure Grid1CellDblClick(const Column: TColumn; const Row: Integer);
    procedure Label7Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    FMouseDown: Boolean;
    FLastMousePos: TPointF;
    FCurrentYear: Integer;
    FCurrentMonth: Integer;

    procedure SyncHorizontalScrollBoxes(DeltaX: Single);
    procedure SyncVerticalScrollBoxes(DeltaY: Single);
    procedure UpdateCalendar;
    procedure UpdateLabels;
    procedure DataSetToGrid(DataSet: TDataSet; Grid: TGrid);
    procedure AdjustColumnWidth(Grid: TGrid; FieldName: string;
      Width: Integer);
    function FindColumnIndexByFieldName(Grid: TGrid;
      FieldName: string): Integer;
    procedure onAfterLoadDatabase;
    procedure onAfterPopulate(Month, Year : integer);

  public
    { Public declarations }
    procedure LoadForm;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.SysUtils, System.DateUtils, System.Hash, View.Login;

{$R *.fmx}


procedure TfrmMain.BtnLeftClick(Sender: TObject);
begin
  Dec(FCurrentMonth);
  if FCurrentMonth < 1 then
  begin
    FCurrentMonth := 12;
    Dec(FCurrentYear);
  end;

  UpdateLabels;
  UpdateCalendar;
  Main.CALENDAR.ScrollToFirstTask;
end;

procedure TfrmMain.BtnRightClick(Sender: TObject);
begin
  Inc(FCurrentMonth);
  if FCurrentMonth > 12 then
  begin
    FCurrentMonth := 1;
    Inc(FCurrentYear);
  end;

  UpdateLabels;
  UpdateCalendar;
  Main.CALENDAR.ScrollToFirstTask;
end;

procedure TfrmMain.UpdateCalendar;
begin
  Main.CALENDAR.Populate(FCurrentYear, FCurrentMonth);
end;

procedure TfrmMain.UpdateLabels;
const
  MonthNames: array[1..12] of string = ('JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO', 'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO');
begin
  lbYear.Text := IntToStr(FCurrentYear);
  lbMonth.Text := MonthNames[FCurrentMonth];
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Grid1.Tag := 0;
  Grid2.Tag := 1;

  LoadForm;

  ScrollBox1.OnMouseDown := ScrollBoxMouseDown;
  ScrollBox1.OnMouseMove := ScrollBoxMouseMove;
  ScrollBox1.OnMouseUp := ScrollBoxMouseUp;

  ScrollBox2.OnMouseDown := ScrollBoxMouseDown;
  ScrollBox2.OnMouseMove := ScrollBoxMouseMove;
  ScrollBox2.OnMouseUp := ScrollBoxMouseUp;

  ScrollBox3.OnMouseDown := ScrollBoxMouseDown;
  ScrollBox3.OnMouseMove := ScrollBoxMouseMove;
  ScrollBox3.OnMouseUp := ScrollBoxMouseUp;

  ScrollBox3.Height := RectHours.Height;
end;

procedure TfrmMain.LoadForm;
begin
  FCurrentYear := YearOf(Now);
  FCurrentMonth := MonthOf(Now);
  Main.CALENDAR.Initialize(ScrollBox2, ScrollBox1, RectHours);

  UpdateLabels;
  UpdateCalendar;

  Main.CALENDAR
      .AfterLoadDatabase(onAfterLoadDatabase)
      .AfterPopulate(onAfterPopulate)
      .LoadTasksFromDatabase(FCurrentYear, FCurrentMonth)
      .ScrollToStandardPosition;

  Main.CALENDAR.LoadSortedTasks(DataSource1).LoadOverdueTasks(DataSource2);
end;

procedure TfrmMain.Grid1CellDblClick(const Column: TColumn; const Row: Integer);
begin
  if DataSource1.DataSet.RecordCount <= 0 then
    exit;
  DataSource1.DataSet.RecNo := Row + 1;
  Main.CALENDAR.ScrollToPos
  (
    Main.CALENDAR.GetTaskPosition(DataSource1.DataSet.FieldByName('id').AsString)
  );
end;
procedure TfrmMain.Grid2CellDblClick(const Column: TColumn; const Row: Integer);
begin
  if DataSource2.DataSet.RecordCount <= 0 then
    exit;
  DataSource2.DataSet.RecNo := Row + 1;
  Main.CALENDAR.ScrollToPos
  (
    Main.CALENDAR.GetTaskPosition(DataSource2.DataSet.FieldByName('id').AsString)
  );
end;

procedure TfrmMain.Label7Click(Sender: TObject);
begin
  Main.FORMS.Infos;
end;

procedure TfrmMain.Grid1GetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
var
  Grid: TGrid;
  DataSource: TDataSource;
  Field: TField;
begin
  Grid := Sender as TGrid;
  if Grid = nil then Exit;

  if Grid.Tag = 0 then
    DataSource := DataSource1
  else if Grid.Tag = 1 then
    DataSource := DataSource2
  else
    Exit;

  if not Assigned(DataSource) or not Assigned(DataSource.DataSet) or not DataSource.DataSet.Active then
    Exit;

  DataSource.DataSet.RecNo := ARow + 1;

  if ACol < DataSource.DataSet.FieldCount then
  begin
    Field := DataSource.DataSet.Fields[ACol];

    if Field is TDateField then
    begin
      Value := FormatDateTime('dd/mm', Field.AsDateTime);
    end
    else
    begin
      Value := Field.AsString;
    end;
  end;
end;

procedure TfrmMain.Rectangle5Click(Sender: TObject);
begin
  Main.FORMS.TaskManager;
end;

procedure TfrmMain.ScrollBox1ViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
begin
  if ScrollBox3.ViewportPosition.Y <> ScrollBox1.ViewportPosition.Y then
    ScrollBox3.ViewportPosition := PointF(ScrollBox3.ViewportPosition.X, ScrollBox1.ViewportPosition.Y);
end;

procedure TfrmMain.ScrollBox2ViewportPositionChange(Sender: TObject;
  const OldViewportPosition, NewViewportPosition: TPointF;
  const ContentSizeChanged: Boolean);
begin
  if ScrollBox2.ViewportPosition.X <> ScrollBox1.ViewportPosition.X then
    ScrollBox1.ViewportPosition := PointF(ScrollBox2.ViewportPosition.X, ScrollBox1.ViewportPosition.Y);
end;

procedure TfrmMain.ScrollBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FMouseDown := True;
  FLastMousePos := PointF(X, Y);
end;

procedure TfrmMain.ScrollBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  DeltaX, DeltaY: Single;
begin
  if FMouseDown then
  begin
    DeltaX := FLastMousePos.X - X;
    DeltaY := FLastMousePos.Y - Y;

    if Sender = ScrollBox1 then
    begin
      SyncVerticalScrollBoxes(DeltaY);
    end
    else if Sender = ScrollBox2 then
    begin
      SyncHorizontalScrollBoxes(DeltaX);
    end
    else if Sender = ScrollBox3 then
    begin
      SyncVerticalScrollBoxes(DeltaY);
    end;

    FLastMousePos := PointF(X, Y);
  end;
end;

procedure TfrmMain.ScrollBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FMouseDown := False;
end;

procedure TfrmMain.SpeedButton1Click(Sender: TObject);
begin
  if NOT Assigned(frmLogin) then
    Application.CreateForm(TfrmLogin, frmLogin);

  Application.MainForm := frmLogin;
  frmLogin.Show;
  FrmMain.Close;
end;

function TfrmMain.FindColumnIndexByFieldName(Grid: TGrid; FieldName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Grid.ColumnCount - 1 do
  begin
    if SameText(Grid.Columns[i].Header, FieldName) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TfrmMain.AdjustColumnWidth(Grid: TGrid; FieldName: string; Width: Integer);
var
  ColumnIndex: Integer;
begin
  ColumnIndex := FindColumnIndexByFieldName(Grid, FieldName);
  if ColumnIndex >= 0 then
    Grid.Columns[ColumnIndex].Width := Width;
end;

procedure TfrmMain.SyncHorizontalScrollBoxes(DeltaX: Single);
begin
  ScrollBox1.ViewportPosition := PointF(ScrollBox1.ViewportPosition.X + DeltaX, ScrollBox1.ViewportPosition.Y);
  ScrollBox2.ViewportPosition := PointF(ScrollBox2.ViewportPosition.X + DeltaX, ScrollBox2.ViewportPosition.Y);
end;

procedure TfrmMain.SyncVerticalScrollBoxes(DeltaY: Single);
begin
  ScrollBox1.ViewportPosition := PointF(ScrollBox1.ViewportPosition.X, ScrollBox1.ViewportPosition.Y + DeltaY);
  ScrollBox3.ViewportPosition := PointF(ScrollBox3.ViewportPosition.X, ScrollBox3.ViewportPosition.Y + DeltaY);
end;

procedure TfrmMain.onAfterLoadDatabase;
begin
  DataSetToGrid(DataSource1.DataSet, Grid1);
  DataSetToGrid(DataSource2.DataSet, Grid2);
end;

procedure TfrmMain.onAfterPopulate(Month, Year : integer);
begin
  FCurrentYear := Year;
  FCurrentMonth := Month;
  UpdateLabels;
end;

procedure TfrmMain.DataSetToGrid(DataSet: TDataSet; Grid: TGrid);
var
  i: Integer;
  StringColumn: TStringColumn;
begin
  if not Assigned(DataSet) then
    exit;

  for i := Grid.ColumnCount - 1 downto 0 do
    Grid.RemoveObject(Grid.Columns[i]);

  for i := 0 to DataSet.FieldCount - 1 do
  begin
      StringColumn := TStringColumn.Create(nil);
      StringColumn.Header := DataSet.Fields[i].DisplayName;
      StringColumn.TagString := DataSet.Fields[i].FieldName;
      Grid.AddObject(StringColumn);

      if DataSet.Fields[i].Visible = false then
        Grid.Columns[i].Visible := false;
  end;

  AdjustColumnWidth(Grid, 'Title', 150);
  AdjustColumnWidth(Grid, 'Date', 45);
  AdjustColumnWidth(Grid, 'StartTime', 35);
  AdjustColumnWidth(Grid, 'EndTime', 35);

  Grid.RowCount := DataSet.RecordCount;
end;

end.

