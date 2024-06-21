unit Controller.Forms;

interface

uses
  Controller.Interfaces, View.DialogMessage, System.UITypes;

type
  TControllerForms = class(TInterfacedObject, iControllerForms)
    private
      FParent : iController;
      FDialogMessage : TfrmDialogMessage;
    public
      constructor Create(Parent : iController);
      destructor Destroy; override;
      class function New(Parent : iController): iControllerForms;
      function DialogMessage(aTitle,aDescription : string; aType : TDialogMessageType) : iControllerForms;
      function TaskManager(aTaskId : string = ''): iControllerForms;
      function Infos: iControllerForms;
  end;

var
  ControllerForms: iControllerForms;

implementation

uses
  System.SysUtils, View.TaskManager, View.Info;

{ TControllerForms }

constructor TControllerForms.Create(Parent: iController);
begin
  FParent := Parent;
end;

destructor TControllerForms.Destroy;
begin
  FreeAndNil(FDialogMessage);
  inherited;
end;

function TControllerForms.DialogMessage(aTitle,aDescription : string; aType : TDialogMessageType): iControllerForms;
begin
  Result := self;

  if Assigned(FDialogMessage) then
    FreeAndNil(FDialogMessage);

  FDialogMessage := TfrmDialogMessage.Create(nil);
  try
    FDialogMessage.lbTitle.Text := aTitle;
    FDialogMessage.lbDescription.Text := aDescription;

    if aType = dmError then
      FDialogMessage.SetMessageError(true);

    if aType = dmSuccess then
      FDialogMessage.SetMessageSucess(true);

    FDialogMessage.Show;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;

function TControllerForms.Infos: iControllerForms;
begin
  Result := self;

  if Assigned(frmInfo) then
    FreeAndNil(frmInfo);

  frmInfo := TfrmInfo.Create(nil);

  try
    frmInfo.ShowModal;
  finally
    frmTaskManager.Free;
  end;
end;

class function TControllerForms.New(Parent: iController): iControllerForms;
begin
  Result := self.Create(Parent);
end;

function TControllerForms.TaskManager(aTaskId: string = ''): iControllerForms;
begin
  Result := self;

  frmTaskManager := TfrmTaskManager.Create(nil);

  try
    if aTaskId <> '' then
      frmTaskManager.LoadTask(aTaskId);

    frmTaskManager.ShowModal(procedure(ModalResult: TModalResult)
    begin
      if ModalResult = mrOk then
      begin
        DialogMessage('','Tarefa salva com sucesso!', dmSuccess);
      end;

      if ModalResult = mrYes then
      begin
        DialogMessage('','Tarefa excluida com sucesso!', dmSuccess);
      end;
    end);
  finally
    frmTaskManager.Free;
  end;
end;

end.

