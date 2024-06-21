unit Model.Entity.Task;

interface

uses
  System.Generics.Collections, System.Classes, Rest.Json, System.JSON, SimpleAttributes;

type
  [Tabela('Task')]
  TTask = class
  private
    FID: string;
    FTitle: String;
    FDescription: String;
    FDate: TDate;
    FStartTime: String;
    FEndTime: String;
    FColor: String;
    FObservations: String;
    FIsCompleted: String; {TBooleanField}
    FUSERID : string;
    procedure SetIsCompleted(Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    function Clone: TTask;
  published
    [Campo('ID'), PK]
    property ID: string read FID write FID;
    [Campo('Title')]
    property Title: String read FTitle write FTitle;
    [Campo('Description')]
    property Description: String read FDescription write FDescription;
    [Campo('Date')]
    property Date: TDate read FDate write FDate;
    [Campo('StartTime')]
    property StartTime: String read FStartTime write FStartTime;
    [Campo('EndTime')]
    property EndTime: String read FEndTime write FEndTime;
    [Campo('Color')]
    property Color: String read FColor write FColor;
    [Campo('Observations')]
    property Observations: String read FObservations write FObservations;
    [Campo('IsCompleted')]
    property IsCompleted: String read FIsCompleted write SetIsCompleted;
    [Campo('USERID')]
    property USERID: String read FUSERID write FUSERID;

    function ToJSONObject: TJsonObject;
    function ToJsonString: string;
  end;

implementation

uses
  System.UIConsts;

{ TTask }
function TTask.Clone: TTask;
begin
  Result := TTask.Create;
  try
    Result.FID := Self.FID;
    Result.FTitle := Self.FTitle;
    Result.FDescription := Self.FDescription;
    Result.FDate := Self.FDate;
    Result.FStartTime := Self.FStartTime;
    Result.FEndTime := Self.FEndTime;
    Result.FColor := Self.FColor;
    Result.FObservations := Self.FObservations;
    Result.FIsCompleted := Self.FIsCompleted;
  except
    Result.Free;
    raise;
  end;
end;

constructor TTask.Create;
begin

end;

destructor TTask.Destroy;
begin

  inherited;
end;

procedure TTask.SetIsCompleted(Value: string);
begin
  if Value = '-1' then
    Value := '1';

  FIsCompleted := Value;
end;

function TTask.ToJSONObject: TJsonObject;
begin
  Result := TJson.ObjectToJsonObject(Self);
end;

function TTask.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.

