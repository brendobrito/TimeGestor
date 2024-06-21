unit Model.Entity.User;

interface

uses
  System.Generics.Collections, System.Classes, Rest.Json, System.JSON, SimpleAttributes;

type
  [Tabela('USERS')]
  TUSER = class
  private
    FID: String;
    FNAME: String;
    FEMAIL: String;
    FPASSWORD: String;

  public
    constructor Create;
    destructor Destroy; override;

  published
    [Campo('ID'), PK]
    property ID: String read FID write FID;
    [Campo('NAME')]
    property NAME: String read FNAME write FNAME;
    [Campo('EMAIL')]
    property EMAIL: String read FEMAIL write FEMAIL;
    [Campo('PASSWORD')]
    property PASSWORD: String read FPASSWORD write FPASSWORD;

    function ToJSONObject: TJsonObject;
    function ToJsonString: string;
  end;

implementation

constructor TUSER.Create;
begin

end;

destructor TUSER.Destroy;
begin

  inherited;
end;

function TUSER.ToJSONObject: TJsonObject;
begin
  Result := TJson.ObjectToJsonObject(Self);
end;

function TUSER.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

end.

