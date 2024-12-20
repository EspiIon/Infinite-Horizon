unit affichage;


interface
uses SDL2, SDL2_image,structure,mouvement,bonus,SysUtils,hud;

procedure defBackground(var background:TabBackground;var background2:Tbackground;sdlRenderer:PSDL_Renderer;taille:integer);
procedure defplayer(var player:Tplayer;var sdlRenderer:PSDL_Renderer);
procedure RenderCopyPlayer(var player:Tplayer;var sdlrenderer:PSDL_Renderer);
procedure AnimationPlayer(var player:Tplayer;var sdlRenderer:PSDL_Renderer);
procedure ChangementSprite(var texture:PSDL_Texture;var anim:animation);
procedure RenderCopyBackground(var sdlRenderer:PSDL_Renderer;background:TabBackground);
procedure RenderCopyNiveau(var sdlRenderer:PSDL_Renderer;niveau:Tniveau);
procedure RenderCopyEnemies(var sdlRenderer:PSDL_Renderer; enemies:Tenemies);
procedure RenderCopyBackgroundSimple(var sdlRenderer:PSDL_Renderer;background2:Tbackground);
procedure RenderCopyBonus(var sdlRenderer:PSDL_Renderer;bonus:Tbonuses);
procedure applicationTexture(var player:Tplayer;var floor,textenemie:PSDL_Texture ;var sdlRenderer:PSDL_Renderer);
procedure ChargementTexture(var anim:animation;var sdlRenderer:PSDL_Renderer);
procedure destroyAll(var player:Tplayer;var floor:PSDL_Texture;var background:TabBackground;var background2:Tbackground;var enemies:Tenemies;var bonus:Tbonuses;var niveau:Tniveau;var pattern:TabPattern;hasbeenloaded:boolean);
procedure creationWindow(var sdlWindow1:PSDL_Window;var sdlRenderer:PSDL_Renderer);

implementation
procedure defBackground(var background:TabBackground;var background2:Tbackground;sdlRenderer:PSDL_Renderer;taille:integer);
var i:integer;
begin
    //initialisation du background
    background2.surface:= IMG_Load('./assets/background2.png');
    background2.texture:=SDL_CreateTextureFromSurface(sdlRenderer,background2.surface);
    background2.destRect.x:=0;
    background2.destRect.y:=0;
    background2.destRect.w:=900;
    background2.destRect.h:=500;
for i:=1 to taille do //on parcourt les 3 backgrounds
        begin
        //initialisation des backgrounds
        background[i].surface:= IMG_Load('./assets/background.png');
        background[i].texture:= SDL_CreateTextureFromSurface(sdlRenderer,background[i].surface);
        background[i].destRect.x:=0+900*(i-1);
        background[i].destRect.y:=0;
        background[i].destRect.w:=900;
        background[i].destRect.h:=500;
        background[i].x:=background[i].destRect.x
        end;
end;

procedure defplayer(var player:Tplayer;var sdlRenderer:PSDL_Renderer);
begin
    //initialisation du joueur
    player.destRect.x:=20;
    player.destRect.y:=380;
    player.destRect.w:=50;
    player.destRect.h:=70;
end;

procedure ChangementSprite(var texture:PSDL_Texture;var anim:animation);
begin
    //
    anim.counter:=anim.counter+1;
    if (round(anim.counter/((anim.time*10)/anim.frame)))>=anim.frame then //on regarde si on a atteint la fin de l'animation c'est a dire le nombre d'iteration multiplié par le temps d'animation sur le nombre d'image 
        begin
        anim.counter:=0;//si c'est le cas on remet le compteur a 0
        end;
    texture:=anim.textures[round(anim.counter/((anim.time*10)/anim.frame))]; //on change la texture du joueur en fonction du compteur
end;
procedure AnimationPlayer(var player:Tplayer;var sdlRenderer:PSDL_Renderer);
var ImageWidth, ImageHeight: Integer;
begin
    if (player.ishurt)then //si le joueur est touché
        begin
            ChangementSprite(player.texture,player.hurt);//si le joueur est touché on change la source de l'animation
            if player.hurt.counter =0 then//si le compteur de l'animation est a 0
                player.ishurt:=False;//on arrete l'animation
        end
    else if player.isAttacking then //si le joueur attaque
        begin
        ChangementSprite(player.texture,player.attack); //on change la source de l'animation
        if player.attack.counter=0 then //si le compteur de l'animation est a 0
            player.isAttacking:=False; //on arrete l'animation
        end
    else if player.right or player.left then //si le joueur bouge
        begin
        ChangementSprite(player.texture,player.run); //on change la source de l'animation
        end
    else if (not player.right) and  (not player.left) then //si le joueur ne bouge pas
    begin
       ChangementSprite(player.texture,player.idle); //on change la source de l'animation
    end;
SDL_QueryTexture(player.texture, nil, nil, @ImageWidth, @ImageHeight); //on recupere la taille de l'image
player.destRect.w:=round(ImageWidth*1.944); //on definit la largeur du joueur proportionnellement a la largeur de l'image

end;

procedure RenderCopyBackground(var sdlRenderer:PSDL_Renderer;background:TabBackground);
var i:integer;
begin
    for i:=1 to 3 do
        begin
            SDL_RenderCopy(sdlRenderer,background[i].texture,nil, @background[i].destRect);//rendu du background
        end;
end;
procedure RenderCopyNiveau(var sdlRenderer:PSDL_Renderer;niveau:Tniveau);
var l,i,k:integer;
begin
for l:=1 to 3 do //on parcourt les 3 niveaux
            begin
                for i:=0 to niveau.taillex-1 do //on parcourt les blocs en x
                    for k:=0 to niveau.tailley-1 do //on parcourt les blocs en y
                        begin
                            if niveau.lniveau[l][i][k].bloc =True then //si il y a un bloc
                                begin
                                SDL_RenderCopy(sdlRenderer,niveau.lniveau[l][i][k].texture,nil, @niveau.lniveau[l][i][k].destRect); //on fait un rendu du bloc
                                end;
                        end;
            end;
end;
procedure RenderCopyEnemies(var sdlRenderer:PSDL_Renderer; enemies:Tenemies);
var i:integer;
begin
for i:=0 to enemies.taille-1 do //on parcourt les ennemies
    begin
        if enemies.lEnemies[i].alive then //si l'ennemie est vivant
            begin
                SDL_RenderCopy(sdlRenderer,enemies.texture,nil, @enemies.lEnemies[i].destRect); //on fait un rendu de l'ennemie
            end;
    end;
end;
procedure RenderCopyBonus(var sdlRenderer:PSDL_Renderer;bonus:Tbonuses);
var i:integer;
begin
for i:=1 to 2 do //on parcourt les bonus
    begin
        if (bonus.lbonus[i].id > 0) then //si le bonus est actif
            begin
                SDL_RenderCopy(sdlRenderer,bonus.lbonus[i].texture,nil, @bonus.lbonus[i].destRect); //on fait un rendu du bonus
            end;
    end;
end;
procedure RenderCopyBackgroundSimple(var sdlRenderer:PSDL_Renderer;background2:Tbackground);
begin
SDL_RenderCopy(sdlrenderer,background2.texture,nil,@background2.destRect);//rendu du background
end;
procedure ChargementTexture(var anim:animation;var sdlRenderer:PSDL_Renderer);
var surface:PSDL_Surface;
    i:integer;
    charArray:array[0..255] of char; //tableau de char
    src:string;
begin
setlength(anim.textures,anim.frame);//on definit la taille du tableau de texture
for i:=0 to anim.frame-1 do //on parcourt les frames de l'animation
    begin
        
        src:=anim.folder+IntToStr(i+1)+'.png'; //on definit le chemin de l'image comme etant le dossier de l'animation plus le numero de l'image
        StrPCopy(charArray, src); //on copie le chemin dans le tableau de char
        surface:= iMG_Load(pchar(charArray));//on charge l'image
        anim.textures[i]:=SDL_CreateTextureFromSurface(sdlRenderer,surface);//on cree la texture a partir de l'image
    end;
    sdl_freeSurface(surface);//on libere la surface
end;

procedure creationWindow(var sdlWindow1:PSDL_Window;var sdlRenderer:PSDL_Renderer);
var icon:PSDL_Surface;
begin
    icon:=iMG_Load('./assets/icon.png');//icone de la fenetre
    sdlWindow1:=SDL_CreateWindow('Infinite Horizon',450,150,900,500, SDL_WINDOW_SHOWN);//creation de la fenetre
    SDL_SetWindowIcon(sdlwindow1, icon);//ajout de l'icone a la fenetre
    sdlRenderer:=SDL_CreateRenderer(sdlWindow1, -1, 0);//creation du rendu
end;
procedure applicationTexture(var player:Tplayer;var floor,textenemie:PSDL_Texture ;var sdlRenderer:PSDL_Renderer);
var surface:PSDL_Surface;
begin
    //chargement des textures
    ChargementTexture(player.idle,sdlRenderer);
    ChargementTexture(player.run,sdlRenderer);
    ChargementTexture(player.hurt,sdlRenderer);
    ChargementTexture(player.attack,sdlRenderer);
    ChargementTexture(player.slash.anim,sdlRenderer);
    surface:=iMG_Load('./assets/terre.png');//chargement de la surface de l'image
    floor:=SDL_CreateTextureFromSurface(sdlrenderer,surface);//creation de la texture a partir de la surface
    sdl_freeSurface(surface); //liberation de la surface
    surface:=iMG_Load('./assets/slime.png'); //chargement de la surface de l'image
    textenemie:=SDL_CreateTextureFromSurface(sdlrenderer,surface);//creation de la texture a partir de la surface
    sdl_freeSurface(surface);////liberation de la surface
end;
procedure RenderCopyPlayer(var player:Tplayer;var sdlrenderer:PSDL_Renderer);
begin   
        SDL_RenderCopyEx(sdlrenderer,player.slash.texture,nil,@player.slash.destRect,45,nil,SDL_FLIP_NONE);//rendu des attaques
        AnimationPlayer(player,sdlRenderer); //animation du joueur
        if (player.left) or (not player.isright) then //si le joueur va a gauche
        begin
            SDL_RenderCopyEx(sdlrenderer, player.texture, nil, @player.destRect, 0, nil,SDL_FLIP_HORIZONTAL); //on fait un rendu du joueur en le retournant
        end
        else
            begin
                SDL_RenderCopy(sdlrenderer,player.texture,nil,@player.destRect); //on fait un rendu du joueur
            end;
end;
procedure destroyAll(var player:Tplayer;var floor:PSDL_Texture;var background:TabBackground;var background2:Tbackground;var enemies:Tenemies;var bonus:Tbonuses;var niveau:Tniveau;var pattern:TabPattern;hasbeenloaded:boolean);
var i,k,l:integer;
begin
    if hasbeenloaded then //si les textures ont ete chargées
        begin
            SDL_DestroyTexture(player.texture);//destruction de la texture du joueur
            SDL_DestroyTexture(floor);
            for i:=1 to 3 do
                begin
                    SDL_DestroyTexture(background[i].texture);//destruction de la texture du background
                end;
            sdl_DestroyTexture(background2.texture);//destruction de la texture du background
            SDL_DestroyTexture(enemies.texture);//destruction de la texture des ennemies
            for l:= 1 to 3 do
                begin
                    for i:=0 to niveau.taillex-1 do //on parcourt les blocs en x
                        for k:=0 to niveau.tailley-1 do//on parcourt les blocs en y
                            begin
                                if niveau.lniveau[l][i][k].bloc then//si il y a un bloc
                                    SDL_DestroyTexture(niveau.lniveau[l][i][k].texture);//destruction de la texture du bloc
                            end;
                end;
            for i:=1 to 2 do
                sdl_DestroyTexture(bonus.lbonus[i].texture);//destruction de la texture des bonus
            for l:= 1 to 5 do
                begin
                    for i:=0 to 4 do//on parcourt les 5 blocs de longueur
                        for k:=0 to 4 do//on parcourt les 5 blocs de hauteur
                            begin
                                SDL_DestroyTexture(pattern[l][i][k].texture);//destruction de la texture du pattern
                            end;
                end;
        end;
    
end;
end.
