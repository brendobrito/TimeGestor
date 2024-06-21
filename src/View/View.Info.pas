unit View.Info;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  FMX.Objects;

type
  TfrmInfo = class(TForm)
    Rectangle1: TRectangle;
    Layout2: TLayout;
    lbStatus: TLabel;
    Label1: TLabel;
    Memo1: TMemo;
    StyleBook1: TStyleBook;
    Button5: TButton;
    Rectangle6: TRectangle;
    procedure Button5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInfo: TfrmInfo;

implementation

{$R *.fmx}

procedure TfrmInfo.Button5Click(Sender: TObject);
begin
  close;
end;

procedure TfrmInfo.FormShow(Sender: TObject);
begin
  self.Width := Application.MainForm.Width;
  self.Height := Application.MainForm.Height;
  self.Left :=  Application.MainForm.Left;
  self.Top :=  Application.MainForm.Top;
end;

end.
