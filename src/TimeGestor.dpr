program TimeGestor;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Main in 'View\View.Main.pas' {frmMain},
  Helper.Calendar in 'Helper\Helper.Calendar.pas',
  Helper.HourBlocks in 'Helper\Helper.HourBlocks.pas',
  View.TaskManager in 'View\View.TaskManager.pas' {frmTaskManager},
  Controller.Interfaces in 'Controller\Controller.Interfaces.pas',
  Controller.Main in 'Controller\Controller.Main.pas',
  Model.Connection.Interfaces in 'Model\Connection\Model.Connection.Interfaces.pas',
  Model.Connection.SQLite in 'Model\Connection\Model.Connection.SQLite.pas',
  Model.DAO.Factory in 'Model\DAO\Model.DAO.Factory.pas',
  Model.DAO.Interfaces in 'Model\DAO\Model.DAO.Interfaces.pas',
  Model.DAO.SQL in 'Model\DAO\Model.DAO.SQL.pas',
  Model.Entity.Task in 'Model\Entity\Model.Entity.Task.pas',
  Controller.Task in 'Controller\Entity\Controller.Task.pas',
  Controller.Generic in 'Controller\Controller.Generic.pas',
  View.DialogMessage in 'View\View.DialogMessage.pas' {frmDialogMessage},
  Controller.Forms in 'Controller\Controller.Forms.pas',
  Controller.Calendar in 'Controller\Controller.Calendar.pas',
  Controller.Utils in 'Controller\Controller.Utils.pas',
  View.Info in 'View\View.Info.pas' {frmInfo},
  DCPrijndael in 'Controller\DCPrijndael.pas',
  Controller.Loading in 'Controller\Controller.Loading.pas',
  View.Login in 'View\View.Login.pas' {FrmLogin},
  Controller.Users in 'Controller\Controller.Users.pas',
  Model.Entity.User in 'Model\Entity\Model.Entity.User.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.Run;
end.
