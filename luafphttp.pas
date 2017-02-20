unit LuafpHttp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Lua, LuaPas,fphttpclient;
var
  HTTPClient: TFPHTTPClient;

procedure InitLuafpHttpFunc(L: Plua_State);
// lua函数调用参数示例
function test(L: Plua_State): Integer; cdecl;
function get(L: Plua_State): Integer; cdecl;
function post(L: Plua_State): Integer; cdecl;

implementation

function tabletotext(L:Plua_State; Index:Integer):String;
var n :integer;
begin
    Result := '';
    if lua_istable(L,Index) then begin
        n := lua_gettop(L);
        lua_pushnil(L);
        while (lua_next(L, n) <> 0) do begin
            If (Result <>'') then
               Result:=Result+'&';
            Result := Result + EncodeURLElement(lua_tostring(L, -2)) +'='+ EncodeURLElement(lua_tostring(L, -1));
            lua_pop(L, 1);
        end;
    end else if lua_isstring(L,Index) then
       Result := lua_tostring(L,Index);
end;

function test(L: Plua_State): Integer; cdecl;
var
  i,n :integer;
  s :string;
begin
  i:=1;
  s:='';
  n := lua_gettop(L);
  while(i<=n)do
  begin
      s:= s + '--' + IntToStr(i) +':'+ lua_tostring(L,i);
      Inc(i);
  end;
  lua_pushstring(L,s);
  Result := 1;
end;

function get(L: Plua_State): Integer; cdecl;
var
  url :string;
  s :string;
  n :integer;
begin
  n := lua_gettop(L);
  if lua_isstring(L,n) then
    begin
      url := lua_tostring(L,n);
      s:= HTTPClient.Get(url);
      lua_pushstring(L,s);
    end
  else begin
      lua_pushboolean(L,false);
  end;
  Result := 1;
end;
function post(L: Plua_State): Integer; cdecl;
var
  url :string;
  s :string;
  n :integer;
begin
  n := lua_gettop(L);
  if(n = 1) then
  begin
      if lua_isstring(L,1) then
        begin
          url := lua_tostring(L,1);
          s:= HTTPClient.Post(url);
          lua_pushstring(L,s);
        end
      else begin
          lua_pushboolean(L,false);
      end;
  end
  else if(n = 2) then
  begin
      if lua_isstring(L,1) then
      begin
          url := lua_tostring(L,1);
      end;
      if lua_istable(L,2) then
      begin
          s := tabletotext(L,2);
      end;
      s:= HTTPClient.formPost(url,s);
      lua_pushstring(L,s);
  end;

  Result := 1;
end;

procedure InitLuafpHttpFunc(L: Plua_State);
begin
  //  初始化
  if HTTPClient = nil then
  begin
      HTTPClient := TFPHTTPClient.Create(nil);
  end;
end;

end.

