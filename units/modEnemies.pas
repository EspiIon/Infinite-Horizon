unit modenemies;

interface
uses structure,SDL2,SDL2_image,mouvement;
procedure DamageEnemies(var player:Tplayer;var enemies:Tenemies);
procedure chasing(player:Tplayer;var enemies:Tenemies);
procedure deathEnemie(var enemies:Tenemies);
procedure initialisationEnemies(var enemies:Tenemy;niveau:Tniveau);
procedure HitboxEnemies(var enemies:Tenemies;var niveau:Tniveau);
procedure GravityEnemie(var enemies:Tenemies);
procedure hitboxPlayerEnemies(var enemies:Tenemies;var player:Tplayer);

implementation

procedure DamageEnemies(var player:Tplayer;var enemies:Tenemies);
var i:integer;
begin
if (player.cooldown.hurt=0) and (not player.isAttacking) then
    begin
        for i:=0 to enemies.taille-1 do
            begin
                if enemies.lEnemies[i].alive then
                begin
                    if SDL_HasIntersection(@player.destRect,@enemies.lEnemies[i].destRect) then
                        begin
                            player.ishurt:=true;
                            player.cooldown.hurt:=150;
                            player.life:=player.life-enemies.damage;
                            player.push:=True;
                            enemies.lEnemies[i].reaction:=1;
                        end;
                end;
            end;
    end;
end;
procedure chasing(player:Tplayer;var enemies:Tenemies);
var x,i:integer;
begin
    for i:=0 to enemies.taille-1 do //on parcourt les ennemies
        begin
            x:=player.destRect.x-enemies.lEnemies[i].destRect.x; 
            if x = 0 then //si le joueur est a la meme position que l'ennemi
                x:=1;//on evite la division par 0
            if (enemies.lEnemies[i].Xpre/x <0) or (enemies.lEnemies[i].reaction>0) then //si l'ennemi doit changer de direction
                enemies.lEnemies[i].reaction:=enemies.lEnemies[i].reaction+1; //on incremente la reaction
            if  enemies.lEnemies[i].reaction =40 then //si la reaction est a 40 (400 ms)
                enemies.lEnemies[i].reaction:=0; //on remet la reaction a 0
            
            if (abs(x) <enemies.range) and (enemies.lEnemies[i].reaction=0) and enemies.lEnemies[i].alive then //si le joueur est a portée de l'ennemi
                begin
                    if x>0 then //si le joueur est a droite de l'ennemi
                        begin
                            enemies.lEnemies[i].speedx:=enemies.speedxMax; //l'ennemi va a droite
                        end
                    else //si le joueur est a gauche de l'ennemi
                        begin
                            enemies.lEnemies[i].speedx:=-enemies.speedxMax; //l'ennemi va a gauche
                        end;
                end
            else //si le joueur n'est pas a portée de l'ennemi
                begin
            enemies.lEnemies[i].speedx:=0; //l'ennemi ne bouge pas
                end;
        enemies.lEnemies[i].Xpre :=x; //on enregistre la position de l'ennemi l'instant t pour l'utiliser a t+1
        end;
end;
procedure deathEnemie(var enemies:Tenemies);
var i:integer;
begin
for i:=0 to enemies.taille-1 do //pour chaque ennemie
    begin
        if enemies.lEnemies[i].life <= 0 then //si l'ennemi n'a plus de vie
            enemies.lEnemies[i].alive:=False; //l'ennemi est mort
    end;
end;
procedure hitboxPlayerEnemies(var enemies:Tenemies;var player:Tplayer);
var i:integer;
    leftmob,rightmob,bottommob,topmob:TSDL_Rect;
begin
for i:=0 to enemies.taille-1 do //pour chaque ennemi
    begin
        if enemies.lEnemies[i].alive then //si l'ennemi est vivant
            begin
                //on cree des rectangles pour les cotés de l'ennemi
                leftmob.y:=enemies.lEnemies[i].destRect.y+5;
                leftmob.x:=enemies.lEnemies[i].destRect.x;
                leftmob.h:=enemies.lEnemies[i].destRect.h;
                leftmob.w:=2;

                rightmob.y:=enemies.lEnemies[i].destRect.y+5;
                rightmob.x:=enemies.lEnemies[i].destRect.x+enemies.lEnemies[i].destRect.w;
                rightmob.h:=enemies.lEnemies[i].destRect.h;
                rightmob.w:=2;

                bottommob.y:=enemies.lEnemies[i].destRect.y+enemies.lEnemies[i].destRect.h+1;
                bottommob.x:=enemies.lEnemies[i].destRect.x+5;
                bottommob.h:=1;
                bottommob.w:=enemies.lEnemies[i].destRect.w;

                topmob.y:=enemies.lEnemies[i].destRect.y;
                topmob.x:=enemies.lEnemies[i].destRect.x+10;
                topmob.h:=2;
                topmob.w:=enemies.lEnemies[i].destRect.w-20;
                if SDL_HasIntersection(@player.destRect,@bottommob) then //si le joueur la tete de l'ennemi
                    begin
                        player.touchbottom:=True; //le joueur touche le plafond
                    end;
                if SDL_HasIntersection(@player.destRect,@topmob) then //si le joueur touche le bas de l'ennemi
                    begin
                        player.touchfloor:=True; //le joueur touche le sol
                    end
                else
                    player.touchfloor:=player.touchfloor; //le joueur ne touche pas le sol
                if SDL_HasIntersection(@player.destRect,@leftmob)then //si le joueur touche le coté gauche de l'ennemi
                    begin
                        player.speedx:=enemies.lEnemies[i].speedx-5; //le joueur recois une vitesse negative pour le deplacer a droite
                        player.touchleft:=True; //le joueur touche le coté droit
                    end
                else if SDL_HasIntersection(@player.destRect,@rightmob) then //si le joueur touche le coté droit de l'ennemi
                    begin
                        player.speedx:=enemies.lEnemies[i].speedx+5;//le joueur recois une vitesse positive pour le deplacer a gauche
                        player.touchright:=True;//le joueur touche le coté gauche
                    end;
            end;
    end;
end;
procedure initialisationEnemies(var enemies:Tenemy;niveau:Tniveau);
var rx,ry:integer;
begin
    rx:=random(20);//on choisie un bloc sur le quel va apparaitre l'ennemie
    ry:=5;
    while niveau.lniveau[enemies.l][rx][ry].bloc = False do //on verifie qu'il n'y a pas de bloc a l'endroit ou l'enemie apparait, si il y en a un on monte jusqu'a ce qu'il n'y en ai plus
        begin
            ry:=ry-1;                    
        end;
    //le rang est egale a i+round(enemies.taille/3)*(l-1) car il y a (enemies.taille/3) par ecran
    enemies.destRect.y:=niveau.lniveau[enemies.l][rx][ry].destRect.y-niveau.lniveau[enemies.l][rx][ry].destRect.h;
    enemies.destRect.x:=50*rx+niveau.lniveau[enemies.l][0][0].destRect.x;
    //remise a zero des parametres de l'enemie
    enemies.alive:=True;
    enemies.life:=100;
end;
procedure GravityEnemie(var enemies:Tenemies);
var g:real;
    i:Integer;
begin
    g:=40;
    for i:=0 to enemies.taille-1 do //pour chaque ennemie
        begin
            if not enemies.lEnemies[i].touchfloor then //si l'ennemi ne touche pas le sol
                begin
                    enemies.lEnemies[i].speedy:=enemies.lEnemies[i].speedy+g*0.01; //on applique la force de gravité
                end;
            if (enemies.lEnemies[i].touchfloor) and (enemies.lEnemies[i].speedy>=0) then //si l'ennemi touche le sol
                enemies.lEnemies[i].speedy:=0; //la vitesse en y de l'ennemi est nulle
            enemies.lEnemies[i].destRect.y:= enemies.lEnemies[i].destRect.y + round(enemies.lEnemies[i].speedy); //on deplace l'ennemi en y
        end;
end;
procedure HitboxEnemies(var enemies:Tenemies;var niveau:Tniveau);
var leftbloc,rightbloc,topbloc:TSDL_Rect;
	i,k,l,n:integer;
begin 
    for n:=0 to enemies.taille-1 do //pour chaque ennemie
        begin
        enemies.lEnemies[n].touchfloor:=False; //l'ennemi ne touche pas le sol par defaut 

            for l:=1 to 3 do //pour chaque ecran
                begin
                    for i:=0 to niveau.taillex-1 do //pour chaque bloc en x
                        begin
                            for k:=0 to 5 do //pour chaque bloc en y
                                begin
                                    if niveau.lniveau[l][i][k].bloc = True then
                                        begin
                                            //on cree des rectangles pour les cotés du bloc
                                            leftbloc.y:=niveau.lniveau[l][i][k].destRect.y;
                                            leftbloc.x:=niveau.lniveau[l][i][k].destRect.x;
                                            leftbloc.h:=niveau.lniveau[l][i][k].destRect.h;
                                            leftbloc.w:=1;

                                            rightbloc.y:=niveau.lniveau[l][i][k].destRect.y;
                                            rightbloc.x:=niveau.lniveau[l][i][k].destRect.x+niveau.lniveau[l][i][k].destRect.w;
                                            rightbloc.h:=niveau.lniveau[l][i][k].destRect.h;
                                            rightbloc.w:=1;

                                            topbloc.y:=niveau.lniveau[l][i][k].destRect.y-1;
                                            topbloc.x:=niveau.lniveau[l][i][k].destRect.x+5;
                                            topbloc.h:=2;
                                            topbloc.w:=niveau.lniveau[l][i][k].destRect.w;
                                                
                                                if SDL_HasIntersection(@enemies.lEnemies[n].destRect,@topbloc) then //si l'ennemi touche le bas du bloc
                                                    begin
                                                        enemies.lEnemies[n].touchfloor:=True;//l'ennemi touche le sol
                                                        enemies.lEnemies[n].speedy:=1;//l'ennemi recois la normal du sol
                                                    end
                                                else
                                                    enemies.lEnemies[n].touchfloor:=enemies.lEnemies[n].touchfloor;
                                                if SDL_HasIntersection(@enemies.lEnemies[n].destRect,@leftbloc) then //si l'ennemi touche le coté gauche du bloc
                                                    begin
                                                        enemies.lEnemies[n].speedx:=-1; // l'ennemi va a gauche
                                                    end;
                                                if SDL_HasIntersection(@enemies.lEnemies[n].destRect,@rightbloc) then //si l'ennemi touche le coté droit du bloc
                                                    begin
                                                        enemies.lEnemies[n].speedx:=1; //l'ennemi va a droite
                                                    end
                                                
                                            end;
                                    end;
                            end;
                    end;
        end;
end;
end.