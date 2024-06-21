unit Controller.Loading;

interface

uses System.SysUtils, System.UITypes, FMX.Types, FMX.Controls, FMX.StdCtrls,
  FMX.Objects, FMX.Effects, FMX.Layouts, FMX.Forms, FMX.Graphics, FMX.Ani,
  FMX.VirtualKeyboard, FMX.Platform;

type
  TLoading = class
  private
    class var LayoutLoad: TLayout;
    class var FundoLoad: TRectangle;
    class var Arco: TArc;
    class var Mensagem: TLabel;
    class var Animacao: TFloatAnimation;
    class function GetWidthOfObject(Obj: TFmxObject): Single; static;
  public
    class procedure ShowLoad(const objt: TFMXObject; const msg: string);
    class procedure UpdateMessage(const msg: string); static;
    class procedure ShowFundo(const Frm: Tform);
    class procedure CirLoad(const Frm: Tform; const msg: string);
    class procedure HideLoad;
  end;

implementation

{ TLoading }

class procedure TLoading.UpdateMessage(const msg: string);
begin
  if Assigned(Mensagem) then
  begin
    Mensagem.Text := msg;
  end;
end;

class procedure TLoading.HideLoad;
begin
  if Assigned(LayoutLoad) then
  begin
    try
      if Assigned(Mensagem) then
        Mensagem.DisposeOf;
      if Assigned(Animacao) then
        Animacao.DisposeOf;
      if Assigned(Arco) then
        Arco.DisposeOf;
      if Assigned(FundoLoad) then
        FundoLoad.DisposeOf;
      if Assigned(LayoutLoad) then
        LayoutLoad.DisposeOf;
    except
    end;
  end;

  Mensagem := nil;
  Animacao := nil;
  Arco := nil;
  LayoutLoad := nil;
  FundoLoad := nil;
end;

class procedure TLoading.ShowLoad(const objt: TFMXObject; const msg: string);
var
  FService: IFMXVirtualKeyboardService;
begin
  FundoLoad := TRectangle.Create(objt);
  FundoLoad.Opacity := 0;
  FundoLoad.Parent := objt;
  FundoLoad.Visible := true;
  FundoLoad.Align := TAlignLayout.Contents;
  FundoLoad.Fill.Color := TAlphaColorRec.Black;
  FundoLoad.Fill.Kind := TBrushKind.Solid;
  FundoLoad.Stroke.Kind := TBrushKind.None;
  FundoLoad.Visible := true;

  if objt is TRectangle then begin
    FundoLoad.XRadius := TRectangle(objt).XRadius;
    FundoLoad.YRadius := TRectangle(objt).YRadius;
  end;

  LayoutLoad := TLayout.Create(objt);
  LayoutLoad.Opacity := 0;
  LayoutLoad.Parent := objt;
  LayoutLoad.Visible := true;
  LayoutLoad.Align := TAlignLayout.Contents;
  LayoutLoad.Width := 250;
  LayoutLoad.Height := 78;
  LayoutLoad.Visible := true;

  Arco := TArc.Create(objt);
  Arco.Visible := true;
  Arco.Parent := LayoutLoad;
  Arco.Align := TAlignLayout.Center;
  Arco.Margins.Bottom := 55;
  Arco.Width := 25;
  Arco.Height := 25;
  Arco.EndAngle := 280;
  Arco.Stroke.Color := $FFFEFFFF;
  Arco.Stroke.Thickness := 2;
  Arco.Position.X := trunc((LayoutLoad.Width - Arco.Width) / 2);
  Arco.Position.Y := 0;

  Animacao := TFloatAnimation.Create(objt);
  Animacao.Parent := Arco;
  Animacao.StartValue := 0;
  Animacao.StopValue := 360;
  Animacao.Duration := 0.8;
  Animacao.Loop := true;
  Animacao.PropertyName := 'RotationAngle';
  Animacao.AnimationType := TAnimationType.InOut;
  Animacao.Interpolation := TInterpolationType.Linear;
  Animacao.Start;

  Mensagem := TLabel.Create(objt);
  Mensagem.Parent := LayoutLoad;
  Mensagem.Align := TAlignLayout.Center;
  Mensagem.Margins.Top := 60;
  Mensagem.Font.Size := 13;
  Mensagem.Height := 70;
  Mensagem.Width := GetWidthOfObject(objt);
  Mensagem.FontColor := $FFFEFFFF;
  Mensagem.TextSettings.HorzAlign := TTextAlign.Center;
  Mensagem.TextSettings.VertAlign := TTextAlign.Leading;
  Mensagem.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  Mensagem.Text := msg;
  Mensagem.VertTextAlign := TTextAlign.Leading;
  Mensagem.Trimming := TTextTrimming.None;
  Mensagem.TabStop := false;
  Mensagem.SetFocus;

  FundoLoad.AnimateFloat('Opacity', 0.7);
  LayoutLoad.AnimateFloat('Opacity', 1);
  LayoutLoad.BringToFront;
end;

 class function TLoading.GetWidthOfObject(Obj: TFmxObject): Single;
begin
  if Obj is TForm then
    Result := TForm(Obj).Width - 100
  else if Obj is TRectangle then
    Result := TRectangle(Obj).Width - 100
  else
    Result := 0;
end;

class procedure TLoading.ShowFundo(const Frm: Tform);
begin
  FundoLoad := TRectangle.Create(Frm);
  FundoLoad.Opacity := 0;
  FundoLoad.Parent := Frm;
  FundoLoad.Visible := true;
  FundoLoad.Align := TAlignLayout.Contents;
  FundoLoad.Fill.Color := TAlphaColorRec.Black;
  FundoLoad.Fill.Kind := TBrushKind.Solid;
  FundoLoad.Stroke.Kind := TBrushKind.None;
  FundoLoad.Visible := true;

  LayoutLoad := TLayout.Create(Frm);
  LayoutLoad.Opacity := 0;
  LayoutLoad.Parent := Frm;
  LayoutLoad.Visible := true;
  LayoutLoad.Align := TAlignLayout.Contents;
  LayoutLoad.Width := 250;
  LayoutLoad.Height := 78;
  LayoutLoad.Visible := true;

  FundoLoad.AnimateFloat('Opacity', 0.7);
  LayoutLoad.AnimateFloat('Opacity', 1);
  LayoutLoad.BringToFront;
end;

class procedure TLoading.CirLoad(const Frm: Tform; const msg: string);
begin
  // Arco da animacao...
  Arco := TArc.Create(Frm);
  Arco.Visible := true;
  Arco.Parent := LayoutLoad;
  Arco.Align := TAlignLayout.Center;
  Arco.Margins.Bottom := 55;
  Arco.Width := 25;
  Arco.Height := 25;
  Arco.EndAngle := 280;
  Arco.Stroke.Color := $FFFEFFFF;
  Arco.Stroke.Thickness := 2;
  Arco.Position.X := trunc((LayoutLoad.Width - Arco.Width) / 2);
  Arco.Position.Y := 0;

  // Animacao...
  Animacao := TFloatAnimation.Create(Frm);
  Animacao.Parent := Arco;
  Animacao.StartValue := 0;
  Animacao.StopValue := 360;
  Animacao.Duration := 0.8;
  Animacao.Loop := true;
  Animacao.PropertyName := 'RotationAngle';
  Animacao.AnimationType := TAnimationType.InOut;
  Animacao.Interpolation := TInterpolationType.Linear;
  Animacao.Start;

  // Label do texto...
  Mensagem := TLabel.Create(Frm);
  Mensagem.Parent := LayoutLoad;
  Mensagem.Align := TAlignLayout.Center;
  Mensagem.Margins.Top := 60;
  Mensagem.Font.Size := 13;
  Mensagem.Height := 70;
  Mensagem.Width := Frm.Width - 100;
  Mensagem.FontColor := $FFFEFFFF;
  Mensagem.TextSettings.HorzAlign := TTextAlign.Center;
  Mensagem.TextSettings.VertAlign := TTextAlign.Leading;
  Mensagem.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  Mensagem.Text := msg;
  Mensagem.VertTextAlign := TTextAlign.Leading;
  Mensagem.Trimming := TTextTrimming.None;
  Mensagem.TabStop := false;
  Mensagem.SetFocus;
end;

end.
