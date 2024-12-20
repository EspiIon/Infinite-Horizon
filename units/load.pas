unit load;

interface
uses SDL2,SDL2_image,structure,gen,affichage;
procedure chargementSetting(var player:Tplayer;var enemies:Tenemies;var varBonus:Tbonuses;var niveau:Tniveau;var background:TabBackground;var pattern:TabPattern; var sdlRenderer:PSDL_RENDERER);
procedure starting(var niveau:Tniveau;var pattern:TabPattern;var player:Tplayer;var enemies:Tenemies;var varBonus:Tbonuses;var background:TabBackground;var background2:Tbackground;sdlrenderer:PSDL_Renderer);

implementation
procedure chargementSetting(var player:Tplayer;var enemies:Tenemies;var varBonus:Tbonuses;var niveau:Tniveau;var background:TabBackground;var pattern:TabPattern; var sdlRenderer:PSDL_RENDERER);
var surface:PSDL_Surface;
begin
    
//parametre slash
    player.slash.folder:='./assets/slashRight/slashright';
    player.slash.radius:=70;
    player.slash.frame:=5;
    player.slash.destRect.h:=200;
    player.slash.destRect.w:=200;
    player.slash.time:=20;
    player.slash.damage:=4;
    player.slash.throw:=500;
    //cooldown
    player.cooldown.dash:=0;
    //declartation parametres pour annimation
    player.run.frame:=16;
    player.run.folder:='./assets/run/run';
    player.run.time:=10;

    player.idle.folder:='./assets/idle/idle';
    player.idle.frame:=10;
    player.idle.time:=20;

    player.attack.folder:='./assets/attack/attack';
    player.attack.frame:=5;
    player.attack.time:=4;

    player.hurt.folder:='./assets/hurt/hurt';
    player.hurt.frame:=4;
    player.hurt.time:=7; 

    player.slash.anim.folder:= './assets/slashright/slash';
    player.slash.anim.frame:= 7;
    player.slash.anim.time:= 4;
    player.maxLife:=100;//vie max du joueur
    player.maxStamina:=50;//stamina max du joueur
    player.Maxspeedx:=5;//vitesse max en x du joueur
     //initialisation des tailles
    niveau.taillex:=20;//taille du niveau en x
    niveau.tailley:=5;//taille du niveau en y
    enemies.taille:=6;//taille du tableau d'ennemies

    //parametre bonus
    varbonus.life:=30;
    varbonus.stamina:=50;

    //parametre ennemies
    enemies.speedxMax:=4;
    enemies.damage:=20;
    enemies.range:=450;
    //texture bonus
    surface:=IMG_Load('./assets/heart.png'); //chargement de la surface de l'image
    varbonus.food:=SDL_CreateTextureFromSurface(sdlRenderer,surface); //creation de la texture a partir de la surface
    SDL_FreeSurface(surface);//liberation de la surface
    surface:=IMG_Load('./assets/food.png'); //chargement de la surface de l'image
    varbonus.food:=SDL_CreateTextureFromSurface(sdlRenderer,surface); //creation de la texture a partir de la surface
    SDL_FreeSurface(surface);//liberation de la surface
end;

//remise a zero du jeu
procedure starting(var niveau:Tniveau;var pattern:TabPattern;var player:Tplayer;var enemies:Tenemies;var varBonus:Tbonuses;var background:TabBackground;var background2:Tbackground;sdlrenderer:PSDL_Renderer);
var i:integer;
begin
    randomize();//initialisation du random
    //initialisation des parametres du joueur
    
    //stats
    player.stamina:=50;//stamina du joueur
    player.life:=100;//vie du joueur

    player.distance := 0;//distance parcourue
    
    //boolean joueur
    player.right:=false;//le joueur vas a droite
    player.left:=false;//le joueur vas a gauche
    player.up:=false;//le joueur saute
    player.isright:=True;//le joueur regarde a droite
    player.isAttacking:=False;//le joueur attaque
    player.death:=False;//le joueur est mort
    //vitesses
    player.speedy:=0;//vitesse en y du joueur
    player.speedx:=0;//vitesse en x du joueur
    player.slash.cooldown:=0;//cooldown de l'attaque

    //definition
    defBackground(background,background2,sdlRenderer,3);//definition du fond d'ecran
    defplayer(player,sdlRenderer);//definition du joueur
    
    Generation(niveau,pattern,player,enemies,background);//generation du niveau (3 premires ecrans)
    //inition vie des ennemies
    for i:=0 to enemies.taille-1 do //pour chaque ennemie
        enemies.lEnemies[i].life:=100; //on met la vie a 100
    //boolean
end;
end.