module Geom;

exports

type
    GPoint = record
        x: Integer;
        y: Integer;
    end;
    
    GSize = record
        width: Integer;
        height: Integer;
    end;
    
    GRect = record
        origin: GPoint;
        size: GSize;
    end;
    
function PointInRect(point: GPoint; rect: GRect): Boolean;
function RectInset(rect: GRect; widthInset: Integer; heightInset: Integer): GRect;
function EqualPoints(thing1, thing2: GPoint): Boolean;

private

function EqualPoints(thing1, thing2: GPoint): Boolean;
begin
    EqualPoints := (thing1.x = thing2.x) and (thing1.y = thing2.y);
end;


function RectInset(rect: GRect; widthInset: Integer; heightInset: Integer): GRect;
begin
    RectInset.origin.x := rect.origin.x + widthInset;
    RectInset.size.width := rect.size.width - 2 * widthInset;
    RectInset.origin.y := rect.origin.y + heightInset;
    RectInset.size.height := rect.size.height - 2 * heightInset;
end;


function PointInRect(point: GPoint; rect: GRect): Boolean;
begin
    if (point.x >= rect.origin.x)
       and (point.y >= rect.origin.y)
       and (point.x <= rect.origin.x + rect.size.width)
       and (point.y <= rect.origin.y + rect.size.height) then begin
        PointInRect := True;
    end else begin
        PointInRect := False;
    end;
end. { PointInRect }


