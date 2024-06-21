unit Model.Connection.Interfaces;

interface

uses
  FireDAC.Comp.Client;

type
  iConnection<T> = interface
    ['{DC233F3F-EAA9-41FE-95A0-724B70E85C61}']
    function Connection : T;
  end;

implementation

end.

