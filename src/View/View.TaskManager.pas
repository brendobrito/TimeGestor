unit View.TaskManager;

interface

uses
  System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  FMX.Objects, FMX.StdCtrls, FMX.ListBox, FMX.DateTimeCtrls, FMX.Edit,
  FMX.Controls.Presentation, FMX.Layouts, FMX.TabControl, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Colors, Model.Entity.Task, Controller.Interfaces,
  System.UIConsts, FMX.EditBox, FMX.NumberBox;

type
  TfrmTaskManager = class(TForm)
    Rectangle6: TRectangle;
    rctPrincipal: TRectangle;
    layBotao: TLayout;
    sbSalvar: TSpeedButton;
    sbCancelar: TSpeedButton;
    layCentro: TLayout;
    LayTitleEdit: TLayout;
    Layout30: TLayout;
    Label1: TLabel;
    edtTitle: TEdit;
    Layout31: TLayout;
    Label19: TLabel;
    swActive: TSwitch;
    layTitle: TLayout;
    lbTitle: TLabel;
    sbFechar: TSpeedButton;
    lbid: TLabel;
    lnTop: TLine;
    LayDesc: TLayout;
    Label2: TLabel;
    memo_desc: TMemo;
    LayObs: TLayout;
    edtObs: TEdit;
    Label3: TLabel;
    LayColor: TLayout;
    Label4: TLabel;
    layPeriodo: TLayout;
    Label5: TLabel;
    Layout10: TLayout;
    DateEdit1: TDateEdit;
    TimeEdit1: TTimeEdit;
    Layout14: TLayout;
    Label6: TLabel;
    Layout12: TLayout;
    Layout13: TLayout;
    Label14: TLabel;
    TimeEdit2: TTimeEdit;
    StyleBook1: TStyleBook;
    LytTrash: TLayout;
    Image1: TImage;
    lyt_colors: TLayout;
    procedure sbSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
    FController: iControllerEntity<TTask>;
    FID : string;
    LastSelectedRectangle: TRectangle;
    FColor: TAlphaColor;
    procedure RectangleClick(Sender: TObject);
    procedure SelectColor(TargetColor: TAlphaColor);

  const
   ColorArray: array[0..4] of TAlphaColor = (
      $FF4682B4,  // SteelBlue
      $FFFF4500,  // OrangeRed
      $FF9370DB,  // MediumPurple
      $FF32CD32,  // LimeGreen
      $FFFFD700   // Gold
    );


  public
    procedure LoadTask(id : string);
  end;

var
  frmTaskManager: TfrmTaskManager;

implementation

uses
  Controller.Main, System.DateUtils, System.Generics.Collections,
  System.SysUtils;

{$R *.fmx}

procedure TfrmTaskManager.FormCreate(Sender: TObject);
var
  ChildRectangle: TRectangle;
  i: Integer;
begin
  FController := Main.Task;
  FID := '';

  for i := 0 to High(ColorArray) do
  begin
    ChildRectangle := TRectangle.Create(lyt_colors);
    ChildRectangle.Parent := lyt_colors;
    ChildRectangle.Fill.Color := ColorArray[i];
    ChildRectangle.Stroke.Kind := TBrushKind.None;
    ChildRectangle.Stroke.Color := TAlphaColors.Black;
    ChildRectangle.Stroke.Thickness := 0;
    ChildRectangle.Width := 25;
    ChildRectangle.Height := 25;
    ChildRectangle.Position.X := 3 + i * 30;
    ChildRectangle.Position.Y := 0;
    ChildRectangle.Cursor := crHandPoint;
    ChildRectangle.OnClick := RectangleClick;

    if i = 0 then
    begin
      ChildRectangle.Stroke.Kind := TBrushKind.Solid;
      ChildRectangle.Stroke.Thickness := 1;
      ChildRectangle.Stroke.Dash := TStrokeDash.Dash;
      LastSelectedRectangle := ChildRectangle;
      FColor := ChildRectangle.Fill.Color;
    end;
  end;
end;

procedure TfrmTaskManager.RectangleClick(Sender: TObject);
var
  SelectedRectangle: TRectangle;
begin
  if Sender is TRectangle then
  begin
    SelectedRectangle := TRectangle(Sender);
    if Assigned(LastSelectedRectangle) and (LastSelectedRectangle <> SelectedRectangle) then
    begin
      LastSelectedRectangle.Stroke.Kind := TBrushKind.None;
      LastSelectedRectangle.Stroke.Thickness := 0;
    end;
    SelectedRectangle.Stroke.Kind := TBrushKind.Solid;
    SelectedRectangle.Stroke.Thickness := 1;
    SelectedRectangle.Stroke.Dash := TStrokeDash.Dash;
    LastSelectedRectangle := SelectedRectangle;
    FColor := SelectedRectangle.Fill.Color;
  end;
end;

procedure TfrmTaskManager.SelectColor(TargetColor: TAlphaColor);
var
  ChildRectangle: TRectangle;
  i: Integer;
begin
  for i := 0 to lyt_colors.ChildrenCount - 1 do
  begin
    ChildRectangle := lyt_colors.Children[i] as TRectangle;
    if ChildRectangle.Fill.Color = TargetColor then
    begin
      if Assigned(LastSelectedRectangle) then
      begin
        LastSelectedRectangle.Stroke.Kind := TBrushKind.None;
        LastSelectedRectangle.Stroke.Thickness := 0;
      end;

      ChildRectangle.Stroke.Kind := TBrushKind.Solid;
      ChildRectangle.Stroke.Thickness := 1;
      ChildRectangle.Stroke.Dash := TStrokeDash.Dash;
      LastSelectedRectangle := ChildRectangle;
      FColor := ChildRectangle.Fill.Color;
      Break;
    end;
  end;
end;

procedure TfrmTaskManager.FormShow(Sender: TObject);
var
  NowTime: TTime;
  RoundedHour: TTime;
  CurrentHour, CurrentMinute, CurrentSecond, CurrentMillisecond: Word;
begin
  self.Width := Application.MainForm.Width;
  self.Height := Application.MainForm.Height;
  self.Left := Application.MainForm.Left;
  self.Top := Application.MainForm.Top;

   if FID = '' then
  begin
    LytTrash.Visible := false;
    DateEdit1.Date := Now;
    NowTime := Time;
    DecodeTime(NowTime, CurrentHour, CurrentMinute, CurrentSecond, CurrentMillisecond);
    if CurrentMinute > 0 then
    begin
      Inc(CurrentHour);
      CurrentMinute := 0;
    end;
    if CurrentHour = 24 then
    begin
      CurrentHour := 0;
      DateEdit1.Date := IncDay(Now);
    end;
    RoundedHour := EncodeTime(CurrentHour, CurrentMinute, 0, 0);
    TimeEdit1.Time := RoundedHour;
    TimeEdit2.Time := IncHour(RoundedHour, 1);
  end else begin
    LytTrash.Visible := true;
    DateEdit1.Enabled := false;
    TimeEdit1.Enabled := false;
    TimeEdit2.Enabled := false;
  end;

  edtTitle.SetFocus;
  edtTitle.SelectAll;
end;

procedure TfrmTaskManager.Image1Click(Sender: TObject);
begin
  Main.CALENDAR.RemoveTask(FID);

  Close;
  self.ModalResult := mrYes;
end;

procedure TfrmTaskManager.LoadTask(id: string);
var
  Task: TTask;
begin
  FID := id;

  if id = '' then
  begin
    lbTitle.Text := 'Nova tarefa';
    exit;
  end;

  Task := FController.DAO.SQL.Clear.Where('USERID = '+QuotedStr(Main.CurrentUser.ID)).&End.Find('ID', id).Current;
  if Assigned(Task) then
  begin
    lbid.Text := 'Task id: '+Task.ID;
    lbTitle.Text := 'Editando tarefa';
    edtTitle.Text := Task.Title;
    memo_desc.Text := Task.Description;
    DateEdit1.Date := Task.Date;
    TimeEdit1.Time := StrToTime(Task.StartTime);
    TimeEdit2.Time := StrToTime(Task.EndTime);
    SelectColor(StringToAlphaColor(Task.Color));
    edtObs.Text := Task.Observations;
    swActive.IsChecked := Task.IsCompleted.ToBoolean;
  end;
end;

procedure TfrmTaskManager.sbSalvarClick(Sender: TObject);
var
  Task: TTask;
  TaskList: TObjectList<TTask>;
  StartTime, EndTime, ExistingStartTime, ExistingEndTime: TTime;
  Duration: TTime;
  CurrentDateTime: TDateTime;
  TaskConflict: Boolean;
begin
  if Trim(edtTitle.Text) = '' then
  begin
    Main.FORMS.DialogMessage('', 'O título é obrigatório.', dmError);
    Exit;
  end;

  if Length(edtTitle.Text) < 4 then
  begin
    Main.FORMS.DialogMessage('', 'O título deve ter no mínimo 4 caracteres.', dmError);
    Exit;
  end;

  if Length(edtTitle.Text) > 100 then
  begin
    Main.FORMS.DialogMessage('', 'O título deve ter no máximo 100 caracteres.', dmError);
    Exit;
  end;

  if (Trim(memo_desc.Text) <> '') and (Length(memo_desc.Text) < 10) then
  begin
    Main.FORMS.DialogMessage('', 'A descrição deve ter no mínimo 10 caracteres, se fornecida.', dmError);
    Exit;
  end;

  if Length(memo_desc.Text) > 500 then
  begin
    Main.FORMS.DialogMessage('', 'A descrição deve ter no máximo 500 caracteres.', dmError);
    Exit;
  end;

  if Length(edtObs.Text) > 500 then
  begin
    Main.FORMS.DialogMessage('', 'As observações devem ter no máximo 500 caracteres.', dmError);
    Exit;
  end;

  if FID = '' then
  begin
    CurrentDateTime := Now;
    if DateEdit1.Date < DateOf(CurrentDateTime) then
    begin
      Main.FORMS.DialogMessage('', 'A data da tarefa não pode ser no passado.', dmError);
      Exit;
    end;
  end;

  StartTime := TimeEdit1.Time;
  EndTime := TimeEdit2.Time;
  Duration := EndTime - StartTime;

  if EndTime <= StartTime then
  begin
    Main.FORMS.DialogMessage('', 'O horário de término deve ser posterior ao horário de início.', dmError);
    Exit;
  end;

  if Duration < EncodeTime(0, 5, 0, 0) then
  begin
    Main.FORMS.DialogMessage('', 'A tarefa deve ter uma duração mínima de 5 minutos.', dmError);
    Exit;
  end;

  if (StartTime < EncodeTime(0, 0, 0, 0)) or (StartTime >= EncodeTime(23, 59, 0, 0)) then
  begin
    Main.FORMS.DialogMessage('', 'O horário de início deve ser entre 00:00 e 23:59.', dmError);
    Exit;
  end;

  if (EndTime <= StartTime) or (EndTime > EncodeTime(23, 59, 0, 0)) then
  begin
    Main.FORMS.DialogMessage('', 'O horário de término deve ser entre 00:00 e 23:59.', dmError);
    Exit;
  end;

  if FID = '' then
  begin
   TaskConflict := False;
   TaskList := TObjectList<TTask>.Create;
    try
      FController.DAO.SQL.Clear
        .Where(Format('USERID = %s AND Date = %s',
          [QuotedStr(Main.CurrentUser.ID),
           QuotedStr(FormatDateTime('yyyy-mm-dd', DateEdit1.Date))]))
      .&End
      .Find(TaskList);

      for Task in TaskList do
      begin
        ExistingStartTime := StrToTime(Task.StartTime);
        ExistingEndTime := StrToTime(Task.EndTime);

        if (StartTime < ExistingEndTime) and (EndTime > ExistingStartTime) then
        begin
          TaskConflict := True;
          Break;
        end;
      end;

      if TaskConflict then
      begin
        Main.FORMS.DialogMessage('', 'Conflito de horário encontrado com outra tarefa.', dmError);
        Exit;
      end;
    finally
      TaskList.Free;
    end;
  end;

  Task := FController.DAO.NewObject;

  Task.ID := FID;
  Task.Title := edtTitle.Text;
  Task.Description := memo_desc.Text;
  Task.Date := DateEdit1.Date;
  Task.StartTime := FormatDateTime('hh:nn', TimeEdit1.Time);
  Task.EndTime   := FormatDateTime('hh:nn', TimeEdit2.Time);
  Task.Color := AlphaColorToString(FColor);
  Task.Observations := edtObs.Text;
  Task.IsCompleted := BoolToStr(swActive.IsChecked);

  try
    Main.CALENDAR.SaveTask(Task, true);

    Close;
    self.ModalResult := mrOk;
  except
    on E:Exception do
      Main.FORMS.DialogMessage('', E.Message, dmError);
  end;
end;

end.

