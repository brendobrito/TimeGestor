unit View.DialogMessage;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

type
  TfrmDialogMessage = class(TForm)
    StyleLayout: TStyleBook;
    rctPrincipal: TRectangle;
    Layout5: TLayout;
    Layout2: TLayout;
    Layout1: TLayout;
    lbTitle: TLabel;
    lbDescription: TLabel;
    ImgSucess: TImage;
    ImgError: TImage;
    lbClose: TLabel;
    Layout3: TLayout;
    Layout4: TLayout;
    Timer1: TTimer;
    procedure lbCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetMessageError(const Value: Boolean);
    procedure SetMessageSucess(const Value: Boolean);
  end;

var
  frmDialogMessage: TfrmDialogMessage;

implementation

{$R *.fmx}

procedure TfrmDialogMessage.SetMessageError(const Value: Boolean);
begin
  if Value then
  begin
    rctPrincipal.Fill.Color := $FFecced0;
    lbTitle.FontColor := $FF6b2e33;
    lbDescription.FontColor := $FF6b2e33;
    lbClose.FontColor := $FF6b2e33;
    ImgError.Visible := true;
    ImgSucess.Visible := false;

    if lbTitle.Text = '' then
     lbTitle.Text := 'Erro';

    if lbDescription.Text = '' then
     lbDescription.Text := 'Não foi possível realizar a operação.';

    Timer1.Interval := 7000;
    Timer1.Enabled := true;
  end;
end;

procedure TfrmDialogMessage.SetMessageSucess(const Value: Boolean);
begin
  if Value then
  begin
    rctPrincipal.Fill.Color := $FFD0E2CB;
    lbTitle.FontColor := $FF3E6930;
    lbDescription.FontColor := $FF3E6930;
    lbClose.FontColor := $FF3E6930;

    ImgSucess.Visible := true;
    ImgError.Visible := false;

    if lbTitle.Text = '' then
     lbTitle.Text := 'Sucesso';

    if lbDescription.Text = '' then
     lbDescription.Text := 'Operação realizada com sucesso.';

    Timer1.Interval := 3000;
    Timer1.Enabled := true;
  end;
end;

procedure TfrmDialogMessage.Timer1Timer(Sender: TObject);
begin
  Close;
end;

procedure TfrmDialogMessage.FormShow(Sender: TObject);
begin
  self.Width := Application.MainForm.Width;
  self.Height := Application.MainForm.Height;
  self.Left :=  Application.MainForm.Left;
  self.Top :=  Application.MainForm.Top;

  rctPrincipal.Width := self.Width-200;
end;

procedure TfrmDialogMessage.lbCloseClick(Sender: TObject);
begin
  Close;
end;

end.
