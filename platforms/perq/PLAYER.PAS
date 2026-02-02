program Player;

{ Takes an input filename, which is a borkle2 file that's been
  run through the `krunch` utility, and then displays it.
  This is mainly exploratory / proof of concept work
}

imports CmdParse from CmdParse; { NextId }

var
    incoming: Text;
    filename: String;

const
    programName = 'player';


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



(* -------------------- *)
begin
    InputFilename(filename);
    
    reset(incoming, filename);
    
    Writeln('and there was much rejoycing');

end.
