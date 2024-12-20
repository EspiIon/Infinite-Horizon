program main;
{$R project.res}
{$APPTYPE GUI}

uses SDL2, SDL2_image,structure,affichage,mouvement,bonus,hud,attack,modEnemies,load,gen,menu,crt,scores,sysutils;

var sdlWindow1:PSDL_Window;//fenetre
    sdlRenderer:PSDL_Renderer;//rendu
    player:Tplayer;//joueur
    play, quitter, fond:PSDL_Texture;//textures boutons menu
    quit,quit2,start:boolean;//booleens de fin de jeu et de fermeture
    destination_titre, destination_quitter, destination_fond : TSDL_RECT;
    floor, titre :PSDL_Texture;
    enemies:Tenemies;//ennemies
    pattern:TabPattern;//patterns
    varBonus:Tbonuses;//bonus
    niveau:Tniveau;//niveau
    background:TabBackground;//paysage defilant
    background2:Tbackground;//paysage fixe
    hasbeenloaded:boolean;//booleen de chargement des textures
    liste_scores:TabScores;//liste des scores
    temps_debut:UInt32;//temps de debut de jeu
    

procedure cooldownChecker(var player:Tplayer);
begin
    if player.cooldown.dash>0 then //si le cooldown de la stamina arrive a zero
        begin
            player.cooldown.dash:=player.cooldown.dash-1;//on baisse le cooldown
            if player.cooldown.dash=0 then //si le cooldown de la stamina est egal a 0
                player.speedx:=player.Maxspeedx;
        end;
    if player.cooldown.stamina>0 then //si le cooldown de la stamina arrive a zero
        begin
            player.cooldown.stamina:=player.cooldown.stamina-1;//on baisse le cooldown
        end;
     if player.cooldown.hurt>0 then 
        begin
            player.cooldown.hurt:=player.cooldown.hurt-1;
        end;
    if player.slash.cooldown>0 then
        begin
            player.slash.cooldown:=player.slash.cooldown-1;
        end;
end;

procedure keyinteraction(var player:Tplayer);
var event:TSDL_Event;
begin
while SDL_PollEvent(@event) <> 0 do
    begin
        if Event.type_= SDL_MOUSEBUTTONDOWN then // Bouton de souris pressé
          begin
            if (event.button.button = SDL_BUTTON_LEFT) and (player.slash.cooldown=0) then
                begin
                    player.slash.enable:=True;//activation de l'attaque
                    player.isAttacking:=true;//le joueur est entrain d'attaquer
                end;
            end;
        if event.key.keysym.sym = SDLK_ESCAPE then
            quit2 := true;
    
        if event.type_ = SDL_KEYDOWN then //si une touche est appuyée
            begin
                if event.key.keysym.sym = SDLK_LSHIFT then //si la touche est shift
                    dash(player);//le joueur dash
                if event.key.keysym.sym = SDLK_q then //si la touche est q
                    begin
                        player.isright:=False; //le joueur regarde a gauche
                        player.left:=True; //le joueur vas a gauche
                        player.right:=False;//le joueur ne vas pas a droite
                    end;
                if event.key.keysym.sym = SDLK_d then //si la touche est d
                    begin
                    player.isright:=True; //le joueur regarde a droite
                    player.right:=True; //le joueur vas a droite
                    player.left:=False; //le joueur ne vas pas a gauche
                    end;
                if (event.key.keysym.sym = SDLK_SPACE) and not player.down then //si la touche est espace et que le joueur n'est pas en train de descendre
                    begin
                        if player.speedy=0 then //si le joueur n'est pas en train de sauter ou de tomber
                            begin
                                player.speedy:=-13; //le joueur saute on lui applique une force de 13 dans le sens de la hauteur
                            end;
                        player.up:=True; //le joueur est en train de sauter
                    end;
            end;
         if event.type_ = SDL_QUITEV then //si on appuie sur la croix de la fenetre
            begin
                quit := True; //quitte le jeu
                quit2:=True; //on quitte le menu
            end;

            if event.type_ = SDL_KEYUP then //si une touche est relachée
                begin
                if event.key.keysym.sym = SDLK_q then
                    begin
                        player.left:=false; //le joueur ne vas plus a gauche
                       
                    end;
                if event.key.keysym.sym = SDLK_d then
                    begin
                        player.right:=false; //le joueur ne vas plus a droite
                    end;
                end;
    end;
end;

procedure death(var player:Tplayer;var niveau:Tniveau;var pattern:TabPattern;var enemies:Tenemies;var varBonus:Tbonuses; var background:TabBackground; var background2:Tbackground; var quit2:boolean);
begin
    if (player.destRect.y > 600) or (player.life <= 0)then //si le joueur tombe en dessous de la fenetre
        begin
        player.death:=True;//le joueur est mort
        end;
    if player.death then //si le joueur est mort
        begin
        quit2:=True; //on quitte le jeu mais pas la fenetre
        end;
end;
procedure gameLoop(var sdlwindow1:PSDL_WINDOW;var sdlRenderer:PSDL_Renderer;var player:Tplayer;var enemies:Tenemies;var pattern:TabPattern;var varBonus:Tbonuses;var niveau:Tniveau;var background:TabBackground;var background2:Tbackground);
var 
    top,i:integer;
begin    
    starting(niveau,pattern,player,enemies,varBonus,background,background2,sdlRenderer); //initialisation des veleurs du jeu
    temps_debut := SDL_GetTicks; //temps de debut de jeu
    quit := false;
    //boucle de jeu
    while not quit2 do
    begin
        keyinteraction(player);//interaction avec le clavier et bouton

        //generation
        GenerationBonus(varBonus,niveau,sdlRenderer);//generation des bonus
        proceduralGenEnemies(enemies,niveau);//generation des ennemies
        proceduralGen(niveau,pattern,player,varbonus,sdlRenderer);//generation du niveau
        

        touchbonus(player,niveau,varBonus);//interaction avec les bonus
        
        //gestion des deplacements
        Gravity(player,top);//gravité du joueur
        highness(player);//verifications de la hauteur du joueur
        highnessEnemies(enemies);//verifications de la hauteur des ennemies
        backgroundPlacement(background);//deplacement du fond d'ecran
        hitboxPlayerEnemies(enemies,player);//hitbox du joueur par rapport aux ennemies
        Hitbox(player,background,niveau,enemies);//hitbox du niveau
        chasing(player,enemies);//ennemies qui suivent le joueur;
        HitboxEnemies(enemies, niveau);//hitbox des ennemies
        push(player);//push des enemies sur le joueur
        Gestionposition(player);//gestion de la position du joueur
        move(player,background,enemies,niveau,top,varBonus);//deplacement du joueur
        DistanceParcourue(player);//distance parcourue
        //gestion des attaques
        cooldownChecker(player);//cooldown
       
        
        //positionnement des ennemies
        GravityEnemie(enemies);//gravité des ennemies;
        
        gestionAttack(player,enemies,sdlRenderer);//gestion des attaques
        positionEnemies(player,enemies,niveau);//positionnement des ennemies
        
        DamageEnemies(player,enemies);//degats des enemies
        
        //mort
        deathEnemie(enemies);//mort des ennemies
        death(player,niveau, pattern, enemies, varBonus, background,background2, quit2);//mort du joueur

        //affichage
        AnimationPlayer(player,sdlRenderer);//animation du joueur
        RenderCopyBackgroundSimple(sdlRenderer,background2);//affichage du fond d'ecran 
        RenderCopyBackground(sdlRenderer,background);//affichage du fond d'ecran
        RenderCopyNiveau(sdlRenderer,niveau);//affichage du niveau
        RenderCopyEnemies(sdlRenderer,enemies);//affichage des ennemies
        RenderCopyBonus(sdlRenderer,varBonus);//affichage des bonus
        DrawStats(player,sdlRenderer);//affichage des stats
        RenderCopyPlayer(player,sdlRenderer);//affichage general
		sdl_delay (10);//delais de 10ms par affichage (100fps)
    
        SDL_RenderPresent(sdlRenderer);//affcihage du rendu
        SDL_RenderClear(sdlRenderer);//nettoyage du rendu
        end;
    for i:=0 to enemies.taille do
        enemies.lEnemies[i].alive:=False;
end;

begin
    quit:=false;
    //declaration parametre attack stat
    chargementSetting(player, enemies, varBonus, niveau, background, pattern,sdlRenderer);
    //icon de la fenetre window
    creationWindow(sdlWindow1,sdlRenderer);
    applicationTexture(player,niveau.floor,enemies.texture,sdlRenderer);//chargement des textures
    declarationPattern(pattern,niveau.floor);//definition des patterns
    initialise(sdlwindow1,sdlRenderer,play, quitter, fond,titre,player,destination_quitter,destination_fond, destination_titre);//initialisation du menu
    
    chargerScores(liste_scores);//chargement des scores depuis le fichier
    SDL_SetRenderDrawBlendMode(sdlRenderer, SDL_BLENDMODE_BLEND);
    
    while not quit do
        begin
            affiche_debut(sdlRenderer,play, quitter, fond, titre, player,destination_quitter,destination_fond, destination_titre, liste_scores); //affichage du menu
            processMouseEvent(quit, start,destination_quitter,destination_fond);//gestion des evenements souris dans le menu
            sdl_delay(10);//delais de 10ms par affichage (100fps)
            if start then
                begin
					
                    gameLoop(sdlWindow1,sdlRenderer,player,enemies,pattern,varBonus,niveau,background,background2);//boucle de jeu
                    // Partie terminée, sauvegarde du score
                    fin_partie(player, liste_scores,temps_debut,quit,sdlRenderer);
                    SDL_RenderClear(sdlRenderer);
                    initialise(sdlwindow1,sdlRenderer,play, quitter, fond, titre,player,destination_quitter,destination_fond, destination_titre);
                    start:=False;
                    quit2:=False;
                    hasbeenloaded:=True;
                end;
        end;
    
    
    destroyAll(player,floor,background,background2,enemies,varBonus,niveau,pattern,hasbeenloaded);//destruction des textures
    SDL_DestroyRenderer(sdlRenderer);
    SDL_DestroyWindow(sdlWindow1);
    SDL_Quit;
end.
    
