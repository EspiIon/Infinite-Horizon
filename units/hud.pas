unit hud;

interface
uses structure,SDL2,SDL2_image;
procedure DrawStats(player:Tplayer;var sdlRenderer:PSDL_Renderer);

implementation

procedure DrawStats(player:Tplayer;var sdlRenderer:PSDL_Renderer);
var leftbar,rightbar,topbar,bottombar,healthbar,staminabar:TSDL_Rect;
begin
//life 

//left
leftbar.h:=20;
leftbar.w:=4;
leftbar.x:=30;
leftbar.y:=30;
//right
rightbar.h:=20;
rightbar.w:=4;
rightbar.x:=330;
rightbar.y:=30;


topbar.h:=4;
topbar.w:=300;
topbar.x:=30;
topbar.y:=30;

bottombar.h:=4;
bottombar.w:=300;
bottombar.x:=30;
bottombar.y:=46;

SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 255);
SDL_RenderFillRect(sdlRenderer, @leftbar );
SDL_RenderFillRect(sdlRenderer, @rightbar );
SDL_RenderFillRect(sdlRenderer, @topbar );
SDL_RenderFillRect(sdlRenderer, @bottombar );

healthbar.h:=12;
healthbar.w:=round((296*player.life)/player.maxLife);
healthbar.x:=34;
healthbar.y:=34;

SDL_SetRenderDrawColor(sdlRenderer, 203, 18, 6, 255);
SDL_RenderFillRect(sdlRenderer, @healthbar);
//---------------------
//stamina
leftbar.h:=10;
leftbar.w:=4;
leftbar.x:=30;
leftbar.y:=54;
//right
rightbar.h:=10;
rightbar.w:=4;
rightbar.x:=280;
rightbar.y:=54;

topbar.h:=4;
topbar.w:=250;
topbar.x:=30;
topbar.y:=54;

bottombar.h:=4;
bottombar.w:=250;
bottombar.x:=30;
bottombar.y:=60;
SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 255);
SDL_RenderFillRect(sdlRenderer, @leftbar );
SDL_RenderFillRect(sdlRenderer, @rightbar );
SDL_RenderFillRect(sdlRenderer, @topbar );
SDL_RenderFillRect(sdlRenderer, @bottombar );

staminabar.h:=2;
staminabar.w:=round((246*player.stamina)/player.maxStamina);
staminabar.x:=34;
staminabar.y:=58;
SDL_SetRenderDrawColor(sdlRenderer, 6, 140, 203, 255);
SDL_RenderFillRect(sdlRenderer, @staminabar);
end;

begin
end.