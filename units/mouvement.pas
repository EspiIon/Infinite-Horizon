unit mouvement;


interface
uses structure,SDL2,SDL2_image;
procedure move(var player:Tplayer;var background:TabBackground;var enemies:Tenemies;var niveau:Tniveau;top:integer;var bonus:Tbonuses);
procedure PositionEnemies(player:tplayer;var enemies:Tenemies;var niveau:Tniveau);
procedure Gravity(var player:Tplayer;var top:integer);
procedure Hitbox(var player:Tplayer;background:TabBackground;var niveau:Tniveau;var enemies:Tenemies);
procedure highness(var player:Tplayer);
procedure positionBonus(player:Tplayer;var bonus:Tbonuses;var niveau:Tniveau);
procedure dash(var player:Tplayer);
procedure highnessEnemies(var enemies:Tenemies);
procedure push(var player:Tplayer);
procedure backgroundPlacement(var background:TabBackground);
procedure Gestionposition(var player:Tplayer);
procedure DistanceParcourue(var player:Tplayer);

implementation

procedure push(var player:Tplayer);
begin
    if player.push then //si le joueur est pousse
        begin
            player.speedy:=0; //on lui donne une vitesse verticale negative
            if player.right then //si le joueur va a droite
                player.speedx:=25; //on multiplie sa vitesse horizontale par 2
            if player.left then //si le joueur va a gauche
                player.speedx:=-25; //on multiplie sa vitesse horizontale par 2
            player.up:=True; //le joueur peut monter
            player.push:=false; //le joueur n'est plus pousse
        end;
end;
procedure backgroundPlacement(var background:TabBackground);
var i:integer;
begin
    for i:=1 to 3 do//pour chaque background
        begin
            if background[i].destRect.x<=-900 then //si le background est hors de l'écran
                begin
                    background[i].destRect.x:=background[i].destRect.x+1800;//on le replace a la fin de l'écran
                    background[i].x:=background[i].x+1800; //on ajoute 1800 a la position du background pour qu'il soit a la fin de l'écran
                end;
        end;
end;
procedure move(var player:Tplayer;var background:TabBackground;var enemies:Tenemies;var niveau:Tniveau;top:integer; var bonus:Tbonuses);
var i,k,l:integer;
begin 
    if (player.right = True) then //si le joueur va a droite
        begin
            player.right:=True;//le joueur regarde a droite
            if player.speedx < player.Maxspeedx then
                player.speedx:=player.speedx+1;//on augmente la vitesse du joueur (vers les positifs )
        end
    else if (player.left = True)  then//si le joueur va a gauche
        begin
            player.right:=False;//le joueur regarde a gauche
            if player.speedx > -player.Maxspeedx then
                player.speedx:=player.speedx-1;//on augmente la vitesse du joueur (vers les négatifs )
        end
    else if player.speedx >0 then //si le joueur ne bouge pas et que ça vitess est positive 
        player.speedx:=player.speedx-1 //on diminue la vitesse du joueur
    else if player.speedx<0 then //si le joueur ne bouge pas et que ça vitess est négative
        player.speedx:=player.speedx+1; //on augmente la vitesse du joueur
if (player.destRect.x = 450) and (player.speedx>0) then //si le joueur est au milieu de l'ecran on deplace le niveau au lieu de deplacer le joueur
    begin
        positionBonus(player,bonus,niveau); //on deplace les bonus
        
        for l:=1 to 3 do//pour chaque background
            begin
            //on deplace le background moins vite que le niveau
                background[l].x:=background[l].x-player.speedx/30;
                background[l].destRect.x:=round(background[l].x);
                //on deplace le niveau
                for i:=0 to (niveau.taillex-1) do
                    begin
                        for k:=0 to niveau.tailley-1 do
                            begin
                                niveau.lniveau[l][i][k].destRect.x := niveau.lniveau[l][i][k].destRect.x-player.speedx;//on deplace le niveau avec la vitesse du joueur
                            end;
                    end;
            end;
            
    end
    else
        begin
            player.destRect.x := player.destRect.x+(player.speedx); //on deplace le joueur avec ça vitesse
        end;
end;

procedure DistanceParcourue(var player:Tplayer);//fonction qui ajoute la distance parcourue
begin
player.distance:=(player.distance+player.speedx/10);//on ajoute la distance parcourue
if player.distance < 0 then
    player.distance:=0; //on la met a 0
end;
procedure positionBonus(player:Tplayer;var bonus:Tbonuses;var niveau:Tniveau); //fonction qui deplace les bonus
var i:integer;
begin
for i:=1 to 2 do//pour chaque bonus
    begin
        bonus.lbonus[i].destRect.x:=bonus.lbonus[i].destRect.x-player.speedx;//on deplace les bonus avec la vitesse du joueur
    end;
end;
procedure PositionEnemies(player:tplayer;var enemies:Tenemies;var niveau:Tniveau); //fonction qui deplace les ennemis
var i:integer;
begin
if ((player.destRect.x = 450) and player.right) or ((player.destRect.x = 0) and player.left) then //si le joueur est au milieu de l'ecran et qu'il va a droite ou a gauche
    begin
        for i:=0 to enemies.taille-1 do//pour chaque ennemi
            begin
                enemies.lEnemies[i].destRect.x:=enemies.lEnemies[i].destRect.x-player.speedx+enemies.lEnemies[i].speedx; //on deplace l'ennemi avec sa vitesse moins la vitesse du joueur
            end;
    end
    else
        begin
            for i:=0 to enemies.taille-1 do
                    begin
                        enemies.lEnemies[i].destRect.x:=enemies.lEnemies[i].destRect.x+enemies.lEnemies[i].speedx; //on deplace l'ennemi avec ça vitesse
                        enemies.lEnemies[i].destRect.y:=enemies.lEnemies[i].destRect.y+round(enemies.lEnemies[i].speedy); //on deplace l'ennemi avec ça vitesse
                    end;
        end;
end;
procedure Gravity(var player:Tplayer;var top:integer); //fonction qui gere la gravité
var g:real;
begin
    g:=40; //gravité
    if not player.touchfloor then //si le joueur n'est pas sur le sol
        begin
        player.speedy:=player.speedy+g*0.01; //on augmente la vitesse verticale du joueur
        end;
    if (player.touchfloor) and (player.speedy>=0) then //si le joueur touche le sol et que sa vitesse est positive( donc qu'il tombe)
        player.speedy:=0; //on arrete le joueur 
    player.destRect.y:= player.destRect.y + round(player.speedy);//on deplace le joueur en verticale

end;
procedure Hitbox(var player:Tplayer;background:TabBackground;var niveau:Tniveau; var enemies:Tenemies); //fonction qui gere les collisions
var leftbloc,rightbloc,bottombloc,topbloc:TSDL_Rect;
	i,k,l:integer;
begin
    //valeur par defaut
    player.touchfloor:=False; //le joueur ne touche pas le sol
    player.touchbottom:=False;//le joueur ne touche pas le plafond
    for l:=1 to 3 do
    begin
        for i:=0 to niveau.taillex-1 do
        begin
            for k:=0 to niveau.tailley-1 do
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

                    bottombloc.y:=niveau.lniveau[l][i][k].destRect.y+niveau.lniveau[l][i][k].destRect.h;
                    bottombloc.x:=niveau.lniveau[l][i][k].destRect.x+5;
                    bottombloc.h:=1;
                    bottombloc.w:=niveau.lniveau[l][i][k].destRect.w-20;

                    topbloc.y:=niveau.lniveau[l][i][k].destRect.y-1;
                    topbloc.x:=niveau.lniveau[l][i][k].destRect.x+5;
                    topbloc.h:=1;
                    topbloc.w:=niveau.lniveau[l][i][k].destRect.w-20;

                    if SDL_HasIntersection(@player.destRect,@bottombloc) then //si le joueur touche le plafond
                        begin
                            player.touchbottom:=True; //le joueur touche le plafond
                            player.speedy:=1; //le joueur recois une vitesse verticale positive pour le faire tomber
                        end;
                    if SDL_HasIntersection(@player.destRect,@topbloc) then //si le joueur touche le rectancle du haut
                        begin
                        player.touchfloor:=True; //le joueur touche le sol
                        player.down:=false; //le joueur ne peut pas descendre
                        player.height:=niveau.lniveau[l][i][k].destRect.y -niveau.lniveau[l][i][k].destRect.h-10; //la hauteur du joueur est egale a la hauteur du bloc -10
                        end
                    else
                        player.touchfloor:=player.touchfloor; //le joueur ne touche pas le sol
                    if SDL_HasIntersection(@player.destRect,@leftbloc) then //si le joueur touche le rectangle de gauche
                        begin
                            player.speedx:=-2;//le joueur recois une vitesse negative pour le deplacer a droite
                        end
                    else if SDL_HasIntersection(@player.destRect,@rightbloc)  then //si le joueur touche le rectangle de droite
                        begin
                            player.speedx:=2; //le joueur recois une vitesse positive pour le deplacer a gauche
                        end;
                end;
            end;
        end;
    end;    
end;

procedure highness(var player:Tplayer);
begin
 if (player.speedy=0) and (player.touchfloor) then //si le joueur touche le sol et que sa vitesse verticalle est nulle
        begin
            if ((player.destRect.y-(450-player.destRect.h)) mod 50) <> 0 then //si le joueur n'est pas a la hauteur du sol (multiple de 50)
                begin
                    player.destRect.y := (450-player.destRect.h)+(50)*(round((player.destRect.y-(450-player.destRect.h))/50)); //on le replace a la hauteur de sol la plus proche (l'arrondie de la coordonnee y divisé par 50, multiplié par 50)
                end;
        end;
end;
procedure Gestionposition(var player:Tplayer); //fonction qui verifie la bonne position du joueur
begin
    if player.destRect.x >= 450 then //si le joueur depasse le milieu de l'ecran
        player.destRect.x:=450; //on le replace au milieux de l'ecran
    if player.destRect.x <= 0 then //si le joueur depasse le cote gauche de l'ecran
        player.destRect.x:=0; //on le replace au debut de l'ecran
end;
procedure highnessEnemies(var enemies:Tenemies); //fonction qui verifie la bonne position des ennemis
var i:integer;
begin
for i:=0 to enemies.taille do //pour chaque ennemi
    begin
        if (enemies.lEnemies[i].speedy=0) and (enemies.lEnemies[i].touchfloor) then //si l'ennemi touche le sol et que sa vitesse est nulle
                begin
                    if ((enemies.lEnemies[i].destRect.y-(450-enemies.lEnemies[i].destRect.h)) mod 50) <> 0 then //si l'ennemie n'est pas a la hauteur du sol (multiple de 50)
                        begin
                            enemies.lEnemies[i].destRect.y:=(450-enemies.lEnemies[i].destRect.h)+(50)*(round((enemies.lEnemies[i].destRect.y-(450-enemies.lEnemies[i].destRect.h))/50)); //on le replace a la hauteur de sol la plus proche (l'arrondie de la coordonnee y divisé par 50, multiplié par 50)

                        end;
                end;
    end;
end;
procedure dash(var player:Tplayer);
begin
    if (player.stamina>=10) and (player.cooldown.stamina=0) and (player.cooldown.dash=0) then //si le joueur a assez de stamina
        begin
            player.stamina:=player.stamina-10; //on enleve 10 a la stamina
            player.cooldown.stamina:=25; //on met le cooldown de la stamina a 10 iterations
            player.cooldown.dash:=10; //on met le cooldown de la stamina a 10 iterations
            player.speedx:=player.speedx*5; //on multiplie la vitesse du joueur par 5
        end;
end;
begin
end.
