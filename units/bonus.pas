unit bonus;

interface
uses SDL2, SDL2_image,structure;
procedure GenerationBonus(var bonus:Tbonuses; var niveau:Tniveau;var sdlRenderer:PSDL_Renderer);
procedure touchbonus(var player:Tplayer;niveau:Tniveau;var bonus:Tbonuses);
procedure applyBonus(var player:Tplayer;bonus:Tbonus;varbonus:Tbonuses);

implementation
procedure GenerationBonus(var bonus:Tbonuses; var niveau:Tniveau;var sdlRenderer:PSDL_Renderer);
var i:integer;
    surface:PSDL_Surface;
begin
    randomize();
    for i:=1 to 2 do
        begin
            if (bonus.lbonus[i].destRect.x<=-1000)then
                begin
                    bonus.lbonus[i].destRect.x:=1000+50;
                    bonus.lbonus[i].destRect.y:=200;
                    bonus.lbonus[i].destRect.h:=50;
                    bonus.lbonus[i].destRect.w:=50;
                    bonus.lbonus[i].id:=(random(3)*random(2));
                    if bonus.lbonus[i].id=1 then
                        begin
                            surface:=IMG_Load('./assets/heart.png');
                            bonus.lbonus[i].texture:=SDL_CreateTextureFromSurface(sdlRenderer,surface);
                            SDL_FreeSurface(surface);
                        end
                    else if bonus.lbonus[i].id=2 then
                        begin
                            surface:=IMG_Load('./assets/food.png');
                            bonus.lbonus[i].texture:=SDL_CreateTextureFromSurface(sdlRenderer,surface);
                            SDL_FreeSurface(surface);
                        end;
                end;
        end;
    
end;
procedure applyBonus(var player:Tplayer;bonus:Tbonus;varbonus:Tbonuses);
begin
    if (bonus.id=1) and (player.life<player.maxLife) then
        begin
            if (player.life+varbonus.life>player.maxLife) then
                player.life:=player.maxLife
            else 
                player.life:=player.life+varbonus.life;
        end;
    if (bonus.id=2) and (player.stamina<player.maxStamina) then
        begin
        if (player.stamina+varbonus.stamina>player.maxStamina) then
                player.stamina:=player.maxStamina
            else 
                player.stamina:=player.stamina+varbonus.stamina;
        end;
end;
procedure touchbonus(var player:Tplayer;niveau:Tniveau;var bonus:Tbonuses);
var i:integer;
    begin
    for i:=1 to 2 do
        begin
            if bonus.lbonus[i].id > 0 then
                begin
                    if SDL_HasIntersection(@player.destRect,@bonus.lbonus[i].destRect) then
                        begin
                        applyBonus(player,bonus.lbonus[i],bonus);
                        bonus.lbonus[i].id:=0;
                        end;
                end;
        end;
    end;

end.
