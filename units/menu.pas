unit menu;

interface

uses SDL2, SDL2_image,structure,affichage,SysUtils, SDL2_ttf, scores;

const 
	SURFACEWIDTH=900; //largeur en pixels de la surface de jeu
	SURFACEHEIGHT=500; //hauteur en pixels de la surface de jeu
	IMAGEWIDTH=125; //largeur en pixels de l'image
	IMAGEHEIGHT=75; //auteur en pixels de l'image
	
procedure initialise(var sdlwindow: PSDL_Window; var sdlRenderer:PSDL_Renderer;var play, quitter, fond, titre : PSDL_TEXTURE;var player:Tplayer;var destination_quitter,destination_rect,destination_titre : TSDL_RECT);
procedure affiche_debut(var sdlRenderer: PSDL_Renderer; play, quitter, fond, titre: PSDL_TEXTURE;var player:Tplayer;destination_quitter,destination_rect,destination_titre : TSDL_RECT; liste_scores: TabScores);
procedure processMouseEvent(var quit, lancer : Boolean; var destination_quitter,destination_rect : TSDL_RECT);
procedure fin_partie(var player:Tplayer;var liste_scores:TabScores;temps_debut:UInt32;quit:boolean;var sdlRenderer:PSDL_Renderer);

implementation

//Procedure d'initialisation des elements de l'affichage au début de la partie
procedure initialise(var sdlwindow: PSDL_Window; var sdlRenderer:PSDL_Renderer;var play, quitter, fond, titre : PSDL_TEXTURE;var player:Tplayer;var destination_quitter,destination_rect,destination_titre : TSDL_RECT);
begin

	//Choix de la position et taille de l'image start
	destination_rect.x:=100;
	destination_rect.y:=175;
	destination_rect.w:=IMAGEWIDTH;
	destination_rect.h:=IMAGEHEIGHT;
	
	//Choix de la position et taille de l'image quit
	destination_quitter.x:=100 ;
	destination_quitter.y:=275; ;
	destination_quitter.w:=IMAGEWIDTH;
	destination_quitter.h:=IMAGEHEIGHT;

	//Choix de la position et taille de l'image titre
	destination_titre.x:=200;
	destination_titre.y:=50;
	destination_titre.w:=500;
	destination_titre.h:=75;

	//charger la bibliotheque
	SDL_Init(SDL_INIT_VIDEO);
 	player.idle.folder:='./assets/idle/idle';
    player.idle.frame:=10;
    player.idle.time:=30;	
    							
	//Choix de la position et taille de l'image joueur
	player.destRect.x:=650;
	player.destRect.y:=300;
	player.destRect.w:=100;
	player.destRect.h:=140;		
	
	//chargement des images comme texture
	fond := IMG_LoadTexture(sdlRenderer, 'assets/fond.png');						
	play := IMG_LoadTexture(sdlRenderer, 'assets/button/startbutton.png');
	quitter := IMG_LoadTexture(sdlRenderer, 'assets/button/exit.png');
	titre := IMG_LoadTexture(sdlRenderer, 'assets/titre.png');

end;

//Procedure d'affichage du début de la partie 
procedure affiche_debut(var sdlRenderer: PSDL_Renderer; play, quitter, fond, titre: PSDL_TEXTURE;var player:Tplayer;destination_quitter,destination_rect,destination_titre : TSDL_RECT; liste_scores: TabScores);
var destination_fond : TSDL_RECT;
begin
	ChangementSprite(player.texture,player.idle); // chargement animation joueur
	
	//Choix de la  position et taille du fond
	destination_fond.x:=0;
	destination_fond.y:=0;
	destination_fond.w:=SURFACEWIDTH;
	destination_fond.h:=SURFACEHEIGHT;
	
	SDL_RenderClear(sdlRenderer); //efface le rendu 
	SDL_RenderCopy(sdlRenderer, fond, nil, @destination_fond); 	//Coller l'element fond dans le rendu en cours avec les caracteristiques destination_fond
	SDL_RenderCopy(sdlRenderer, play, nil, @destination_rect); //Coller l'element play dans le rendu en cours avec les caracteristiques destination_rect
	SDL_RenderCopy(sdlRenderer, quitter, nil, @destination_quitter); //Coller l'element quitter dans le rendu en cours avec les caracteristiques destination_quitter
	SDL_RenderCopyEx(sdlrenderer, player.texture, nil, @player.destRect, 0, nil, SDL_FLIP_HORIZONTAL); //animation joueur
	SDL_RenderCopy(sdlRenderer, titre, nil, @destination_titre); //Coller l'element titre dans le rendu en cours avec les caracteristiques destination_titre

	affichageScoreboard(sdlRenderer, liste_scores); //afficher la scoreboard
	
	SDL_RenderPresent(sdlRenderer);//Générer le rendu 
end;

// procédure pour gérer clic souris
procedure processMouseEvent(var quit, lancer : Boolean; var destination_quitter,destination_rect : TSDL_RECT);
var
   x,y : LongInt ;
   Event : TSDL_Event;
begin
	
	while SDL_PollEvent(@Event) <> 0 do //récupérer les évènements
	begin
		if Event.type_= SDL_QUITEV then // si croix, quitte le jeu
			begin
				quit:=True;
			end
		else if Event.type_= SDL_MOUSEBUTTONDOWN then // si clic souris
			begin
				//recuperation des coordonnees
				x:=Event.button.x;
				y:=Event.button.y;
				//test de la position: sur image play
				if (x > destination_rect.x) and ( x < destination_rect.x+destination_rect.w) and (y > (destination_rect.y)) and (y<(destination_rect.y +destination_rect.h)) then
					begin
						lancer := True;
					end
				//test de la position: sur image quitter
				else if ((x > destination_quitter.x) and ( x < destination_quitter.x+destination_quitter.w) and (y > (destination_quitter.y)) and (y<(destination_quitter.y +destination_quitter.h)) ) then
					begin
						quit:=True;
					end;
			end;
	end;
end; 

// procédure pour afficher du texte
procedure afficherLettre(sdlRenderer : PSDL_RENDERER; lettre: AnsiString; x, y:Integer);
var police: PTTF_Font;
    texteSurface: PSDL_Surface;
    texteTexture: PSDL_Texture;
    texteRect: TSDL_Rect;
    couleur: SDL2.TSDL_Color;
    txt : AnsiString ;
    ptxt : pChar ;
    
begin
	txt := lettre;
	ptxt := StrAlloc(length(txt)+1); // allouer un bloc de mémoire de taille (longueur du texte + 1)
    StrPCopy(ptxt,txt); // associe le pointeur au texte
    // Initialiser SDL_ttf pour pouvoir afficher le texte
	if TTF_Init() <> 0 then
	begin
		writeln('Erreur : ', SDL_GetError());
	end;

    // Charger une police
    police := TTF_OpenFont('assets/roboto.ttf', 24);
    
    // Couleur du texte : blanc
    couleur.r := 255;
    couleur.g := 255;
    couleur.b := 255;
    couleur.a := 255;
  
    texteSurface := TTF_RenderUTF8_Blended(police, ptxt, couleur);// Créer une surface
    texteTexture := SDL_CreateTextureFromSurface(sdlRenderer, texteSurface);// Convertir la surface en texture

    // Définir la position et la taille de la zone d'affichage du texte
    texteRect.x := x;                // Position X
    texteRect.y := y;                // Position Y
	texteRect.w := texteSurface^.w;  // Largeur
	texteRect.h := texteSurface^.h;  // Hauteur
	
    // Afficher le rendu
    SDL_RenderCopy(sdlRenderer, texteTexture, nil, @texteRect);
    SDL_RenderPresent(sdlRenderer);

    // Nettoyer les ressources utilisées
    strDispose(ptxt);
    TTF_CloseFont(police);
    TTF_Quit();
    SDL_DestroyTexture(texteTexture);
    SDL_FreeSurface(texteSurface);

end;

// procédure pour afficher la distance et le temps
procedure afficher_distance_temps(sdlRenderer: PSDL_RENDERER ; distance: Integer; temps : UInt32);
var texte : String ;
begin
	texte := 'Vous avez parcouru ' + IntToStr(distance) + 'm en ' + IntToStr(temps) + ' s' ;
	afficherLettre(sdlRenderer, texte , 240, 220);
end;

//Procedure d'initialisation des elements de l'affichage à la fin de la partie
procedure initialise_fin(var sdlwindow: PSDL_Window; var sdlRenderer:PSDL_Renderer;var fond, titre : PSDL_TEXTURE;var destination_titre : TSDL_RECT);
begin
	//Choix de la position et taille de l'image titre
	destination_titre.x:=200;
	destination_titre.y:=50;
	destination_titre.w:=500;
	destination_titre.h:=75;

	//charger la bibliotheque
	SDL_Init(SDL_INIT_VIDEO);
    							
	//chargement des images comme texture
	fond := IMG_LoadTexture(sdlRenderer, 'assets/fond.png');						
	titre := IMG_LoadTexture(sdlRenderer, 'assets/titre.png');
end;

// procédure d'affichage des elements de l'affichage à la fin de la partie
procedure affiche_fin(var sdlRenderer: PSDL_Renderer; fond, titre: PSDL_TEXTURE; destination_titre : TSDL_RECT);
var destination_fond : TSDL_RECT;
begin
	//Choix de la  position et taille du fond
	destination_fond.x:=0;
	destination_fond.y:=0;
	destination_fond.w:=SURFACEWIDTH;
	destination_fond.h:=SURFACEHEIGHT;
	
	SDL_RenderClear(sdlRenderer); //efface le rendu
	SDL_RenderCopy(sdlRenderer, fond, nil, @destination_fond); //coller l'image fond dans le rendu en cours
	SDL_RenderCopy(sdlRenderer, titre, nil, @destination_titre); 	//coller l'image titre dans le rendu en cours

	SDL_RenderPresent(sdlRenderer); //Générer le rendu 

end;

// procédure pour saisir son pseudo à la fin de la partie (affiche également la ditance et le temps)
procedure saisie_nom(sdlRenderer: PSDL_RENDERER; distance, temps : UInt32; var nom: String);
var
	event: TSDL_Event;
	lettre: Char;
	fond, titre : PSDL_TEXTURE; 
	destination_titre : TSDL_RECT;
	sdlwindow: PSDL_Window;
begin
	initialise_fin(sdlwindow, sdlRenderer, fond, titre, destination_titre); 
	affiche_fin(sdlRenderer, fond, titre, destination_titre); 
	nom := ' ';	
	afficher_distance_temps(sdlRenderer, distance, temps);	
	afficherLettre(sdlRenderer, 'Entrez votre pseudo : ', 240, 250);
	while True do
	begin
		// Récupérer tous les événements
		if SDL_PollEvent(@event) <> 0 then
		begin
			// Vérifier si l'événement est une pression de touche
			if event.type_ = SDL_KEYDOWN then
				begin
				case event.key.keysym.sym of
					SDLK_BACKSPACE: // Si Backspace, supprimer la dernière lettre
					begin
					if Length(nom) > 1 then //pour ne pas provoquer d'erreur si il n'y a rien d'écrit
					begin
						SetLength(nom, Length(nom) - 1); // retirer un caractère
						SDL_RenderClear(sdlRenderer); // effacer le rendu
						//afficher nouveau rendu
						affiche_fin(sdlRenderer, fond, titre, destination_titre); 
						afficher_distance_temps(sdlRenderer, distance, temps);	
						afficherLettre(sdlRenderer, 'Entrez votre pseudo : ', 240, 250);
						afficherLettre(sdlRenderer, nom, 470, 250);
					end
					end;
					SDLK_RETURN: // Si Return, sortir de la boucle
					begin
						Exit; 
					end;
					else // Pour toute autre touche
					begin
						if Length(nom) < 10 then // limiter à 10 caractères le pseudo
						begin
							lettre := Char(event.key.keysym.sym); // Convertir en charactère la lettre correspondant à la touche pressée
							nom := nom + lettre; 
							SDL_RenderClear(sdlRenderer); //effacer le rendu
							// afficher le nouveau rendu
							affiche_fin(sdlRenderer, fond, titre, destination_titre);
							afficher_distance_temps(sdlRenderer, distance, temps);	
							afficherLettre(sdlRenderer, 'Entrez votre pseudo : ', 240, 250);
							afficherLettre(sdlRenderer, nom, 470, 250)
						end;
					end;
				end;
		end;
    end;
  end;
end;

// procédure qui récupère le temps, la distance, permet de saisir son pseudo et met à jour la scoreboard
procedure fin_partie(var player:Tplayer;var liste_scores:TabScores;temps_debut:UInt32;quit:boolean;var sdlRenderer:PSDL_Renderer);
var 
    distance: integer;
    nom : String;
    temps_fin: UInt32;
    temps: integer;

begin
if not quit then
    begin
        temps_fin := SDL_GetTicks; //récupère le temps à la fin de la partie en ms
        player.t := temps_fin - temps_debut; //calcul du temps de la partie
        temps := round(player.t) div 1000; //conversion en s
        distance := round(player.distance/10);
        saisie_nom(sdlRenderer, distance, temps, nom);
        ajouterScore(liste_scores, creerScore(nom, distance, temps));
        trierScores(liste_scores);
        ecrireScores(liste_scores);
    end;
end;

begin
end.
