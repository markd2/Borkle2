program Player;

{ Takes an input filename, which is a borkle2 file that's been
  run through the `krunch` utility, and then displays it.
  This is mainly exploratory / proof of concept work
}

imports CmdParse from CmdParse; { NextId }
imports Raster from Raster;
imports Screen from Screen;
imports Geom from Geom; { GPoint, GRect, etc }
imports Draw from Draw; { ClearScreen, etc }

const
    programName = 'player';
    { max width of a line of input, except the string pool }
    MaxLineLength = 128;
    ExpectedVersion = 1;
    MaxConnections = 160; { !!! should do something dynamic }
    MaxBubbles = 160; { !!! should do something dynamic }

type
    LineBuffer = packed array [1..MaxLineLength] of Char;
    
    BBubble = record
        textStart: Integer;
        textEnd: Integer;
    end;
    
    BGeometry = record
        bounds: GRect
    end;

    { connection between bubbles }
    BConnection = record
        bubble1ID: Integer;
        bubble1Center: GPoint;
        bubble2ID: Integer;
        bubble2Center: GPoint;
    end;
    
var
    incoming: Text;
    filename: String;
    readLength: Integer;
    buffer: LineBuffer;
    parsePosition: Integer;
    value : Integer;
    ch: Char;

var
    version: Integer;
    bubbleCount: Integer;
    connectionCount: Integer;
    conn: BConnection;
    allBubbles: packed array[0..MaxBubbles] of BBubble;
    allGeometries: packed array[0..MaxBubbles] of BGeometry;
    
    allConnections: packed array[1..MaxConnections] of BConnection;
    i: Integer;


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

function SnarfInt(what: String) : Integer;
begin
    ReadLine(incoming, buffer, readLength);
    parsePosition := 1;
    
    if ParseInt(buffer, parsePosition, readLength, value) then begin
        SnarfInt := value;
    end else begin
        writeln('could not read ', what);
        exit(Player);
    end;

end; { SnarfInt }


procedure SnarfBubble(var bubble: BBubble; what: String);
var
    textStart, textEnd: Integer;
begin
    ReadLine(incoming, buffer, readLength);
    parsePosition := 1;
    
    if not ParseInt(buffer, parsePosition, readLength, textStart) then begin
        writeln('could not read range start of ', what);
        exit(Player);
    end;
    
    if not ParseInt(buffer, parsePosition, readLength, textEnd) then begin
        writeln('could not read range end of ', what);
        exit(Player);
    end;
    
    bubble.textStart := textStart;
    bubble.textEnd := textEnd;
end; { SnarfBubble }


procedure SnarfGeometry(var geometry: BGeometry; what: String);
var
    x, y, width, height: Integer;
begin
    ReadLine(incoming, buffer, readLength);
    parsePosition := 1;
    
    if not ParseInt(buffer, parsePosition, readLength, x) then begin
        writeln('could not read x of ', what);
        exit(Player);
    end;
    if not ParseInt(buffer, parsePosition, readLength, y) then begin
        writeln('could not read y of ', what);
        exit(Player);
    end;
    if not ParseInt(buffer, parsePosition, readLength, width) then begin
        writeln('could not read width of ', what);
        exit(Player);
    end;
    if not ParseInt(buffer, parsePosition, readLength, height) then begin
        writeln('could not read height of ', what);
        exit(Player);
    end;
    
    with geometry.bounds do begin
        origin.x := x;
        origin.y := y;
        size.width := width;
        size.height := height;
    end;
    
end; { SnarfGeometry }


procedure SnarfConnection(var conn: BConnection; what: String);
var
    thing1, thing2: Integer;
begin
    ReadLine(incoming, buffer, readLength);
    parsePosition := 1;
    
    if not ParseInt(buffer, parsePosition, readLength, thing1) then begin
        writeln('could not read part 1 of ', what);
        exit(Player);
  end;
    
    if not ParseInt(buffer, parsePosition, readLength, thing2) then begin
        writeln('could not read part 2 of ', what);
        exit(Player);
    end;
    
    conn.bubble1ID := thing1;
    conn.bubble2ID := thing2;
    
end; { SnarfConnection }


procedure MopUpConnectionCenters;
var
    i: Integer;
    b1Bounds, b2Bounds: GRect;
begin
    for i := 1 to connectionCount do begin
        with allConnections[i] do begin
            b1Bounds := allGeometries[bubble1ID].bounds;
            b2Bounds := allGeometries[bubble2ID].bounds;
            bubble1Center := RectCenter(b1Bounds);
            bubble2Center := RectCenter(b2Bounds);
        end;
    end;
end;


procedure DrawSomeBubbles;
var
    i: Integer;
    x1, x2, y1, y2: Integer;
const
    drawCount = 20;
begin
    for i := 22 to connectionCount do begin
        with allConnections[i] do begin
{            writeln('connection ', i, bubble1Center.x, bubble1Center.y,
                 bubble2Center.x, bubble2Center.y); }
            x1 := bubble1Center.x;
            x2 := bubble2Center.x;
            y1 := bubble1Center.y;
            y2 := bubble2Center.y;
            
            if x1 > 768 then x1 := 768;
            if x2 > 768 then x2 := 768;
            if y1 > 1024 then y1 := 1024;
            if y2 > 1024 then y2 := 1024;
 {           writeln('    pinned to ', x1, y1, x2, y2); }
            Line(DrawLine, x1, y1, x2, y2, SScreenP);
            
{           Line(DrawLine, bubble1Center.x, bubble1Center.y,
                 bubble2Center.x, bubble2Center.y, SScreenP);
}
        end;
    end;
    writeln('done with lines');
    for i := 0 to bubbleCount - 1 do begin
        writeln('framing ', i, 
        allGeometries[i].bounds.origin.x,
        allGeometries[i].bounds.origin.y,
        allGeometries[i].bounds.size.width,
        allGeometries[i].bounds.size.height);
{        StrokeRect(allGeometries[i].bounds); }
    end;

end; { DrawSomeBubbles }


(* ---- main ---- *)

begin
    (* InputFilename(filename); *) { for now, hardcode during bootstrapping }
    filename := 'modcomp.txt';
    
    reset(incoming, filename);

    version := SnarfInt('version');
    if version <> ExpectedVersion then begin
        writeln('unexpeced version: ', version, 
                ' expecting: ', ExpectedVersion);
        exit(Player);
    end;
    
    bubbleCount := SnarfInt('bubble count');
    writeln('version ', version, 
            'bubble count', bubbleCount);
    for i := 0 to bubbleCount - 1 do begin
        SnarfBubble(allBubbles[i], 'bubble');
    end;
    
    connectionCount := SnarfInt('connection count');
    writeln('connection count ', connectionCount);
    
    for i := 1 to connectionCount do begin
        SnarfConnection(allConnections[i], 'connection');
    end;
    
    for i := 0 to bubbleCount - 1 do begin
        SnarfGeometry(allGeometries[i], 'geometry');
    end;
    
    MopUpConnectionCenters;
    
    ClearScreen;
    
    writeln('data sample');
    writeln('bubble ', allBubbles[1].textStart, allBubbles[1].textEnd);
    with allGeometries[1].bounds do begin
        writeln('geometry ', origin.x, origin.y, size.width, size.height);
    end;
    writeln('connection ', allConnections[1].bubble1ID, 
            allConnections[1].bubble2ID);
    
    DrawSomeBubbles;
    
    writeln('all done');
    writeln('huh');
end.
