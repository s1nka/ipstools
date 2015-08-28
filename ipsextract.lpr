program ipsextract;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils;

const VERSION = '0.0.1';
      AUTHOR  = 's1nka';

procedure PrintVer;
begin
  WriteLn('ipsextract ver ['+VERSION+'] by ['+AUTHOR+']');
end;

procedure PrintHelp;
begin
  WriteLn('usage:');
  WriteLn(' ipsextract <binary file>');
end;

{procedure GetArrayIndex(Text, Word : string; var outArray : Array of Integer);
var i : Integer;
    fooArray : Array of Integer;
begin
  i := 0;
  SetLength(outArray, 0);
  while Pos(Word, Text) > 0 do
  begin
    SetLength(outArray, i+1);
    outArray[i] := Pos(Word, Text);
    WriteLn(Word+' found in '+IntToStr(outArray[i]));
    Delete(Text,1,outArray[i]+Length(Word));
    Inc(i);
  end;
end;}

procedure ProcessFile(inFile: string);
var
  fileContent: String = '';
  fooText: String = '';
  binFile: File of Char;
  ipsFile: TextFile;
  fooChar: Char;
  startIndex, endIndex, totalIndex, curIndex: Integer;
  startArray, endArray: Array of Integer;
begin
  AssignFile(binFile, inFile);
  Reset(binFile);
  while not Eof(binFile) do
  begin
    Read(binFile, fooChar);
    fileContent := fileContent + fooChar;
  end;
  CloseFile(binFile);

  fooText := fileContent;
  startIndex := 0;
  totalIndex := 0;
  SetLength(startArray, 0);
  while Pos('PATCH', fooText) > 0 do
  begin
    SetLength(startArray, startIndex+1);
    curIndex := Pos('PATCH', fooText);
    totalIndex := totalIndex + curIndex;
    startArray[startIndex] := totalIndex;
    //WriteLn('PATCH found in '+IntToStr(startArray[startIndex]));
    Delete(fooText,1,curIndex);
    Inc(startIndex);
  end;

  fooText := fileContent;
  endIndex := 0;
  totalIndex := 0;
  SetLength(endArray, 0);
  while Pos('EOF', fooText) > 0 do
  begin
    SetLength(endArray, endIndex+1);
    curIndex := Pos('EOF', fooText);
    totalIndex := totalIndex + curIndex;
    endArray[endIndex] := totalIndex;
    //WriteLn('EOF found in '+IntToStr(endArray[endIndex]));
    Delete(fooText,1,curIndex);
    Inc(endIndex);
  end;

  for startIndex := 0 to High(startArray) do
    for endIndex := 0 to High(endArray) do
    begin
      if startArray[startIndex] < endArray[endIndex] then
      begin
        WriteLn('found IPS from ' + IntToStr(startArray[startIndex]) + ' to ' + IntToStr(endArray[endIndex]));
        AssignFile(ipsFile,inFile+'.'+IntToStr(startArray[startIndex]) + 'to' + IntToStr(endArray[endIndex]) + '.ips');
        Rewrite(ipsFile);
        Write(ipsFile, Copy(fileContent,startArray[startIndex],endArray[endIndex]-startArray[startIndex]+3));
        CloseFile(ipsFile);
      end;
    end;
end;

begin
  PrintVer;
  if Paramcount < 1 then
  begin
    PrintHelp;
    Exit;
  end;
  if not FileExists(ParamStr(1)) then
  begin
    WriteLn('File [' + ParamStr(1) + '] not found');
    Exit;
  end;
  WriteLn('Processed file [' + ExtractFileName(ParamStr(1)) + ']');
  ProcessFile(ParamStr(1));
end.
