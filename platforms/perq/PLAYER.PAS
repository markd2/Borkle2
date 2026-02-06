program Player;

{ Takes an input filename, which is a borkle2 file that's been
  run through the `krunch` utility, and then displays it.
  This is mainly exploratory / proof of concept work
}

imports CmdParse from CmdParse; { NextId }

const
    programName = 'player';
    { max width of a line of input, except the string pool }
    MaxLineLength = 128;

type
    LineBuffer = packed array [1..MaxLineLength] of Char;

var
    incoming: Text;
    filename: String;
    readLength: Integer;
    buffer: LineBuffer;
    parsePosition: Integer;
    value : Integer;


procedure Usage;
begin
    Writeln(programName, ': borkle2-krunched-input');
    Writeln('    Views the given krunched borkle2 file');
    exit(Player);
end; { Usage }


procedure InputFilename(var filename: String);
var
    appname: CString; { unused }
    isSwitch: Boolean; { unused }
    ch: Char;
begin
    ch := NextId(appname, isSwitch); { consume application name }
    if ch = CCR then Usage; { got app name, but no filename }
    
    ch := NextId(filename, isSwitch);
    if ch <> CCR then Usage;  { got the filename, but there's more stuff }

end; { InputFilename }


(* --------------------- *)

{ There's not really a "readline(fileHandle, buffer)" mechanism available,
  so have this to read from the file into the given buffer, using out
  paramter length for how much was consumed from the file and ended up
  in the buffer.  The rest of the line is discarded if it's longer than
  the buffer.
}
procedure ReadLine(var fileHandle: Text; var buffer: LineBuffer;
                   var length: Integer);
var
    ch: Char;
begin
    length := 0;
    
    { read maxlinelength characters or the next newline }
    while not eoln(fileHandle) do begin
        read(fileHandle, ch);
        if length < MaxLineLength then begin
            length := length + 1;
            buffer[length] := ch;
        end;
    end;
    readln(fileHandle); { consume rest of line and newline }

end; { ReadLine }


function ParseInt(var buffer: LineBuffer; var position: Integer;
                  length: Integer; var value: Integer): Boolean;
var
    sign: Integer; { +1 for positive (default), -1 for negative }
    ok: Boolean; { no early exit, so keep a success flag }
begin
    ok := True;
    value := 0;
    sign := 1;

    { consume spaces }
    while (position <= length) and (buffer[position] = ' ') do begin
        position := position + 1;
    end;
    
    if position > length then begin
        ok := false;
    end else begin
        if buffer[position] = '-' then begin
            sign := -1;
            position := position + 1;
        end;
        
       { if we have nonsense after the sign (if there is one after the
          spaces), then bailout }
        if (position > length) 
              or (buffer[position] < '0') 
              or (buffer[position] > '9') then begin
            ok := False;
        end else begin
            { otherwise consume until see a non-digit, or run out of runway }
            while (position <= length)
                   and (buffer[position] >= '0')
                   and (buffer[position] <= '9') do begin
                 value := value * 10 + (ord(buffer[position]) - ord('0'));
                 position := position + 1;
            end;
            value := value * sign;
        end;
    end;

    ParseInt := ok;
end; { ParseInt }



(* -------------------- *)
begin
    (* InputFilename(filename); *) { for now, hardcode during bootstrapping }
    filename := 'modcomp.txt';
    
    reset(incoming, filename);

    ReadLine(incoming, buffer, readLength);    
    Writeln('and there was much rejoycing');
    
    parsePosition := 1;
    
    if ParseInt(buffer, parsePosition, readLength, value) then begin
        writeln('yay!  got', value);
    end else begin
        writeln('booooo');
    end;

end.
