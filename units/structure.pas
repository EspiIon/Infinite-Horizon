unit structure;

interface
uses SDL2;//on utilise la librairie SDL2


const taille = 3;//nombre de niveaux
//type enemy
type Tenemy=
    record
        surface:PSDL_Surface;
        destRect:TSDL_Rect;
        life,id,speedx,reaction,Xpre,l:integer;
        speedy:real;
        ischasing,alive,touchfloor,canMov:boolean;
    end;
//type enemies (tableau d'enemy, taille du tableau, texture)
type Tenemies=
    record
        lEnemies:array of Tenemy; //tableau de type enemy
        taille:integer;//taille du tableau
        texture:PSDL_Texture;
        speedxMax,damage,range:integer;

    
    end;
//type background
type Tbackground =
    record
    destRect:TSDL_Rect;//rectangle de destination
    surface:PSDL_Surface;//surface
    texture:PSDL_Texture;//texture
    x:real;
    end;
type TabBackground = array[1..taille] of Tbackground;
//type bloc
type Tbloc =
    record
    destRect:TSDL_Rect;//rectangle de destination
    surface:PSDL_Surface;//surface
    texture:PSDL_Texture;//texture
    id:integer;//identifiant
    bloc:boolean;//booléen pour savoir si il y a un bloc a cette position
    end;

type TabBloc = array of array of Tbloc;//tableau de bloc (niveaux)
type Tabniveau = array[1..3] of TabBloc; //tableau niveaux
//type niveau
type Tniveau =
    record
    lniveau:Tabniveau;//tableau de niveaux
    taillex,tailley:integer;//tailles du tableau
    floor:PSDL_Texture;//texture du sol
    end;
//pattern
type TabPattern = array[1..5] of TabBloc;
type Tabtexture = array of PSDL_Texture;

//cooldown
type Tcooldown=
record
    dash:integer;
    stamina:integer;
    hurt:integer;
end;
//type animation
type animation =
record
counter,time,frame:integer;//parametre:temps passé, frames, temps d'animation
folder:string[50];//emplacement des textures
textures:Tabtexture;//tableau de textures
end;
type animationOption =
record
counter,time,frame:integer;//parametre:temps passé, frames, temps d'animation
folder:string[50];//emplacement des textures
end;
//type attack
type Tattack =
record
destRect:TSDL_RECT;//rectangle de destination
damage,radius,frame,counter,time,throw,direction,cooldown:Integer; //paramètres de l'attaque
AnRight,AnLeft,src,folder:string; //paramètres de l'animation
enable:boolean;
texture:PSDL_Texture;//texture actuelle
anim:animation;//textures stocké pour animation
end;
//type player
type Tplayer =
    record
    slash:Tattack;
    destRect:TSDL_Rect;//rectangle de destination
    cooldown:Tcooldown;
    life,maxLife,absoluteTop,height,speedx,stamina,maxStamina,Maxspeedx:integer;//paramètres du joueur
    distance,t,speedy:real;
    texture:PSDL_Texture;//texture
    attack,run,idle,hurt:animation;//texture stocké pour animation
    left,right,up,down,touchfloor,touchbottom,death,isright,isAttacking,ishurt,push,touchleft,touchright:boolean;//booléens
    end;
//type bonus
type Tbonus=
    record
    texture:PSDL_Texture;//texture
    id:integer; //identifiant
    destRect:TSDL_Rect; //rectangle de destination
    end; 
type Tabbonus = array[1..2] of Tbonus; //tableau de bonus

//type bonuses
type Tbonuses =
    record
    food,heart:PSDL_Texture;//textures
    life,stamina:integer;//parazmetres bonus (vie, stamina)
    lbonus:Tabbonus;//tableau de bonus
    end;
type
    TScore = record
        nom: string;
        distance: integer;
        temps: UInt32;
    end;

    TabScores = array of TScore;
    FichierScores = file of TScore;
    
implementation
end.
