unit scores;

interface

uses
    SDL2, SDL2_image, SDL2_ttf, SysUtils, structure;

const
    FILE_NAME = 'scores.dat';
    SCREEN_WIDTH = 900;
    SCREEN_HEIGHT = 500;
    SCORE_RECT_WIDTH = 300;
    SCORE_RECT_HEIGHT = 200;

procedure affichageScoreboard(var sdlRenderer: PSDL_Renderer; scores: TabScores);
procedure lireScores(var scores: TabScores);
procedure ajouterScore(var scores: TabScores; score: TScore);
procedure ecrireScores(scores: TabScores);
function creerScore(nom: string; distance: integer; temps: integer): TScore;
procedure chargerScores(var liste_scores: TabScores);
procedure trierScores(var scores: TabScores);

implementation

procedure chargerScores(var liste_scores: TabScores);
begin
    SetLength(liste_scores, 0);
    if FileExists(FILE_NAME) then
    begin
        // Lire les scores du fichier
        lireScores(liste_scores);
    end
    else
    begin
        // Créer un fichier de scores vide si il n'existe pas
        ecrireScores(liste_scores);
    end;
end;

// charger la police
procedure chargerPolice(var font: PTTF_Font; taille: integer);
begin
    font := TTF_OpenFont('assets/roboto.ttf', taille);
    if font = nil then HALT;
end;

// affichage du rectangle de fond de la scoreboard
procedure affichageRectangle(var sdlRenderer: PSDL_Renderer; rect: TSDL_Rect; couleur: TSDL_Color);
begin
    couleur.a := 128; // pour donner un effet de transparence
    SDL_SetRenderDrawColor(sdlRenderer, couleur.r, couleur.g, couleur.b, couleur.a);
    SDL_RenderFillRect(sdlRenderer, @rect);
end;

// affichage du titre de la scoreboard
procedure affichageTitre(var sdlRenderer: PSDL_Renderer; var sdlSurface: PSDL_Surface; var sdlTexture: PSDL_Texture; rect: TSDL_Rect; titre: string; policeTitre: PTTF_Font; couleur: TSDL_Color);
var
    ptxt: PChar;
begin
    ptxt := StrAlloc(Length(titre) + 1);
    StrPCopy(ptxt, titre);
    couleur.a := 255;
    sdlSurface := TTF_RenderUTF8_Blended(policeTitre, ptxt, couleur);
    sdlTexture := SDL_CreateTextureFromSurface(sdlRenderer, sdlSurface);
    rect.x := rect.x + (rect.w - sdlSurface^.w) div 2;
    rect.y := rect.y + 20;
    rect.w := sdlSurface^.w;
    rect.h := sdlSurface^.h;
    SDL_RenderCopy(sdlRenderer, sdlTexture, nil, @rect);
    StrDispose(ptxt);
end;

function minimum(a, b: integer): integer;
begin
    if a < b then
        minimum := a
    else
        minimum := b;
end;

// affichage de la liste des scores
procedure affichageListeScores(var sdlRenderer: PSDL_Renderer; var sdlSurface: PSDL_Surface; var sdlTexture: PSDL_Texture; rect: TSDL_Rect; scores: TabScores; police: PTTF_Font; couleur: TSDL_Color);
var
    i, yOffset: integer;
    text: string;
    ptxt: PChar;
begin
    yOffset := rect.y + 60;
    couleur.a := 255;
    for i := 0 to minimum(High(scores), 3) do
    begin
		text := IntToStr(i + 1) + ' | ' + scores[i].nom + ' : ' + IntToStr(scores[i].distance) + ' m. / ' + IntToStr(scores[i].temps) + ' s.';        ptxt := StrAlloc(Length(text) + 1);
        StrPCopy(ptxt, text);
        sdlSurface := TTF_RenderUTF8_Blended(police, ptxt, couleur);
        sdlTexture := SDL_CreateTextureFromSurface(sdlRenderer, sdlSurface);
        rect.y := yOffset;
        rect.w := sdlSurface^.w;
        rect.h := sdlSurface^.h;
        SDL_RenderCopy(sdlRenderer, sdlTexture, nil, @rect);
        yOffset := yOffset + sdlSurface^.h + 10;
        StrDispose(ptxt);
    end;
end;

function creerScore(nom: string; distance: integer; temps: integer): TScore;
var
    score: TScore;
begin
    score.nom := nom;
    score.distance := distance;
    score.temps := temps;
    creerScore := score;
end;

// ajouter un score à la liste des scores
procedure ajouterScore(var scores: TabScores; score: TScore);
begin
    SetLength(scores, Length(scores) + 1);
    scores[High(scores)] := score;
end;

// écriture des scores dans le fichier
procedure ecrireScores(scores: TabScores);
var
    f: FichierScores;
    i: integer;
begin
    Assign(f, FILE_NAME);
    Rewrite(f);
    for i := 0 to High(scores) do
    begin
        Write(f, scores[i]);
    end;
    Close(f);
end;

// trier les scores par ordre décroissant
procedure trierScores(var scores: TabScores);
var
    i, j: integer;
    temp: TScore;
begin
    for i := 0 to High(scores) do
    begin
        for j := i + 1 to High(scores) do
        begin
            if scores[j].distance > scores[i].distance then
            begin
                temp := scores[i];
                scores[i] := scores[j];
                scores[j] := temp;
            end;
        end;
    end;
end;

// lire les scores du fichier
procedure lireScores(var scores: TabScores);
var
    f: FichierScores;
    score: TScore;
begin
    Assign(f, FILE_NAME);
    Reset(f);
    SetLength(scores, 0);
    while not EOF(f) do
    begin
        Read(f, score);
        SetLength(scores, Length(scores) + 1);
        scores[High(scores)] := score;
    end;
    Close(f);
end;

// affichage de la scoreboard
procedure affichageScoreboard(var sdlRenderer: PSDL_Renderer; scores: TabScores);
var
    sdlSurface: PSDL_Surface;
    sdlTexture: PSDL_Texture;
    sdlRectangle: TSDL_Rect;
    font: PTTF_Font;
    blanc, noir : TSDL_Color;
begin
    // définition des couleurs
    blanc.r := 240 ;
    blanc.g := 240;
    blanc.b := 240;
    
    noir.r := 0;
    noir.g := 0;
    noir.b := 0;


    if TTF_Init = -1 then HALT;
    chargerPolice(font, 19);

    // rectangle de la scoreboard
    sdlRectangle.x := (SCREEN_WIDTH - SCORE_RECT_WIDTH) div 2;
    sdlRectangle.y := ((SCREEN_HEIGHT - SCORE_RECT_HEIGHT));
    sdlRectangle.w := SCORE_RECT_WIDTH;
    sdlRectangle.h := SCORE_RECT_HEIGHT;

    affichageRectangle(sdlRenderer, sdlRectangle, blanc);
    
    affichageTitre(sdlRenderer, sdlSurface, sdlTexture, sdlRectangle, 'SCOREBOARD', font, noir);
    affichageListeScores(sdlRenderer, sdlSurface, sdlTexture, sdlRectangle, scores, font, noir);
    SDL_RenderPresent(sdlRenderer);
end;


end.
