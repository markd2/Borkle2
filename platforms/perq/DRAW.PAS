module Draw;

exports

imports Geom from Geom;

imports Raster from Raster;
imports Screen from Screen;

procedure ClearScreen;
procedure StrokeRect(rect: GRect);

private

procedure StrokeRect(rect: GRect);
begin
    with rect do begin
        Line(DrawLine,
             origin.x, origin.y,
             origin.x + size.width, origin.y,
             SScreenP);
        Line(DrawLine,
             origin.x, origin.y + size.height,
             origin.x + size.width, origin.y + size.height,
             SScreenP);
        Line(DrawLine,
             origin.x, origin.y,
             origin.x, origin.y + size.height,
             SScreenP);
        Line(DrawLine,
             origin.x + size.width, origin.y,
             origin.x + size.width, origin.y + size.height,
             SScreenP);
    end;
end; { StrokeRect }


procedure ClearScreen;
begin
    writeln(chr(12));
end.
