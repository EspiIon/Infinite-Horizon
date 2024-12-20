unit attack;

interface
uses structure,SDL2,SDL2_image,affichage,SysUtils;
procedure gestionAttack(var player:Tplayer;var enemies:Tenemies;var sdlRenderer:PSDL_Renderer);

implementation
procedure executeAttack(player:Tplayer;var attack:Tattack;var enemies:Tenemies;var sdlRenderer:PSDL_Renderer);
var ImageWidth, ImageHeight,i:integer;
begin
    if attack.enable and not player.ishurt then
    begin
    ChangementSprite(attack.texture,attack.anim);
    SDL_QueryTexture(attack.texture, nil, nil, @ImageWidth, @ImageHeight);
    attack.destRect.w:=ImageWidth;
    attack.destRect.x:=player.destRect.x;
    attack.destRect.y:=player.destRect.y-60;
    if attack.throw =0 then
        begin
            if player.isright then
                begin
                    attack.destRect.x:=player.destRect.x+attack.radius+50;
                end
            else
                begin
                    attack.destRect.x:=player.destRect.x-attack.radius-50;
                    attack.destRect.y:=player.destRect.y-60;
                end;
        end
        else
            begin
            if attack.anim.counter=1 then
                begin
                if player.isright then
                        attack.direction:=1
                else
                    if attack.anim.counter=1 then
                        attack.direction:=-1;
                end;
                if attack.destRect.x <player.destRect.x+attack.throw then
                    attack.destRect.x:=attack.destRect.x+attack.anim.counter*15*attack.direction;
            end;
            attack.counter:=attack.counter+1;
            if (round(attack.anim.counter/((attack.anim.time*10)/attack.anim.frame))+1) =attack.anim.frame then
                begin
                    attack.enable:=False;
                    attack.anim.counter:=0;
                    attack.cooldown:=50;
                    SDL_DestroyTexture(attack.texture);  
                end;
        for i:=0 to (enemies.taille-1) do
            begin
                if SDL_HasIntersection(@enemies.lEnemies[i].destRect,@attack.destRect) then
                    begin
                        enemies.lEnemies[i].life:=enemies.lEnemies[i].life-attack.damage;
                        enemies.lEnemies[i].speedx:=-enemies.lEnemies[i].speedx*2;
                    end;
            end;
        end;
end;
procedure gestionAttack(var player:Tplayer;var enemies:Tenemies;var sdlRenderer:PSDL_Renderer);
begin
    //attaques
    executeAttack(player,player.slash,enemies,sdlRenderer);//slash
end;
begin
end.