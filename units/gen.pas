unit gen;


interface
uses SDL2,SDL2_image,structure,modEnemies;

procedure declarationPattern(var pattern:TabPattern;floor:PSDL_Texture);
procedure proceduralGen(var niveau:Tniveau;pattern:TabPattern;player:Tplayer;var bonus:Tbonuses;var sdlRenderer:PSDL_Renderer);
procedure proceduralGenEnemies(var enemies:Tenemies; var niveau:Tniveau);
procedure Generation(var niveau:Tniveau;pattern:TabPattern;player:Tplayer;var enemies:Tenemies;background:TabBackground);

implementation

procedure definitionBloc(var bloc:Tbloc;floor:PSDL_Texture;i,k:integer);
begin
    bloc.texture:=floor; //on definit la texture du bloc
    bloc.bloc:=True; //le bloc existe
    bloc.destRect.y:=450-50*k; //la position en y du bloc
    bloc.destRect.w:=50; //la largeur du bloc
    bloc.destRect.h:=50; //la hauteur du bloc
    bloc.texture:= floor; //la texture du bloc
end;

procedure declarationPattern(var pattern:TabPattern;floor:PSDL_Texture);
var i,k,n:integer;
begin
    for n:=1 to 5 do //on parcourt les 5 patterns
        begin
            setlength(pattern[n],5,5); //on definit la taille du tableau de bloc
            for i:=0 to 4 do //on parcourt les 5 blocs de longueur
                begin
                    for k:=0 to 4  do //on parcourt les 5 blocs de hauteur
                        begin
                            //if (n=1) and (i<4) and (k=0) then
                            if (n=1) and (k=0)  then //on definit les blocs du pattern 1
                                begin
                                    definitionBloc(pattern[n][i][k],floor,i,k);
                                end;
                             //if (n=2) and (((i >= 3) and (k=0)) or (k =3))then
                             if (n=2) and((k=0)or (k=4)) then //on definit les blocs du pattern 2
                                begin
                                    definitionBloc(pattern[n][i][k],floor,i,k);
                                end;
                            //if (n=3) and (k=3) then
                            if (n=3) and ((k=2) or (k=0)) then //on definit les blocs du pattern 3
                                begin
                                    definitionBloc(pattern[n][i][k],floor,i,k);
                                end;
                            if (n=4) and ((k=0) or (((i=3)or (i=4)) and ((k>1) and (k<4)) ))  then //on definit les blocs du pattern 4
                                begin
                                    definitionBloc(pattern[n][i][k],floor,i,k);
                                end;
                            if (n=5) and (k=0) then //on definit les blocs du pattern 5
                                begin
                                    definitionBloc(pattern[n][i][k],floor,i,k);
                                end;

                        end;
                end;
        end;
end;
procedure Generation(var niveau:Tniveau;pattern:TabPattern;player:Tplayer;var enemies:Tenemies;background:TabBackground); //generation des niveaux
var s,i,k,l,ry,rx,r,rangx:integer;
begin
randomize();
setlength(enemies.lEnemies,enemies.taille);
    for l:=1 to 3 do
        begin
            s:=0;
            ry:=0; 
            setlength(niveau.lniveau[l],niveau.taillex,niveau.tailley);
            while s <> 4 do //4 patterns par ecran
                begin
                    r:=random(5)+1; //on choisie aleatoirement le pattern
                    for i:=0 to round(niveau.taillex/5) do //5 blocs de longeur
                        begin
                            rangx:=i+s*5; //le rang x est i+s*5 car un ecran est compossé de 4 pattern de 5 block de longeur
                            for k:=0 to niveau.tailley-1 do //5 blocs de hauteur
                                begin
                                    if (l=1) and (s=0) then //si on est sur le premier ecran
                                        begin
                                            
                                            niveau.lniveau[l][rangx][k]:=pattern[1][i][k]; //on prend le pattern 1
                                            niveau.lniveau[l][rangx][k].destRect.x:=(rangx)*(50)+(l-1)*1000; //on definit la position en x du bloc
                                        end
                                        else//sinon
                                            begin 
                                                niveau.lniveau[l][rangx][k]:=pattern[r][i][k]; //on prend le pattern r
                                                niveau.lniveau[l][rangx][k].destRect.x:=(rangx)*(50)+(l-1)*1000; //on definit la position en x du bloc
                                            end;
                                end;
                        end;
                    s:=s+1;
                end;
            for i:=0 to round(enemies.taille/3)-1 do //pour chaque enemie
                begin
                    rx:=random(20); //on choisie aleatoirement la position en x de l'enemie
                    //initialisation des enemies 
                    //le rang est egale a i+round(enemies.taille/3)*(l-1) car il y a (enemies.taille/3) enemie par ecran
                    enemies.lEnemies[i+round(enemies.taille/3)*(l-1)].destRect.w:=60; //la largeur de l'enemie
                    enemies.lEnemies[i+round(enemies.taille/3)*(l-1)].destRect.h:=50; //la hauteur de l'enemie
                    if l>1 then
                        enemies.lEnemies[i+round(enemies.taille/3)*(l-1)].alive:=True; //l'enemie est vivant
                        enemies.lEnemies[i+round(enemies.taille/3)*(l-1)].l:=l; //l'ecran de l'enemie
                    ry:=0;
                    while niveau.lniveau[l][rx][ry].bloc = False do //tan qu'il n'y a pas de bloc
                        begin
                            ry:=ry+1; //on monte       
                        end;
                    enemies.lEnemies[i+round(enemies.taille/3)*(l-1)].destRect.y:=niveau.lniveau[l][rx][ry].destRect.y-niveau.lniveau[l][rx][ry].destRect.h; //la position en y de l'enemie
                    enemies.lEnemies[i+round(enemies.taille/3)*(l-1)].destRect.x:=50*rx+(l-1)*1000; //la position en x de l'enemie, 50*rx est la position du bloc et (l-1)*1000 est la position de l'ecran
                end;
        end;
                    
end;
procedure proceduralGen(var niveau:Tniveau;pattern:TabPattern;player:Tplayer;var bonus:Tbonuses;var sdlRenderer:PSDL_Renderer);
var s,i,k,l,r,x,rangx:integer;
begin
    randomize();//initialisation nombre aleatoire
    for l:=1 to 3 do
            begin
                if niveau.lniveau[l][0][0].destRect.x <= -1000 then //ecran est de 900 pixels de long, on prend 1000 pixels pour avoir de la marge
                    begin
                    //on regarde les coordonnées de l'ecran d'avant donc si on est a l'ecran 1 il faut regardé l'ecran 3
                        if l =1 then
                            begin
                                x:=3;
                            end
                        else
                            begin
                                x:=l-1;
                            end;
                        s:=0;
                        while s <> 4 do //s est le nombre de pattern d'un ecran
                            begin
                                
                                r:=random(5)+1;//on choisie aleatoirement le pattern suivant
                                for i:=0 to round(niveau.taillex/5) do //5 bloc de longeur
                                    begin
                                        rangx:=i+s*5; //le rang x est i+s*5 car un ecran est compossé de 4 pattern de 5 block de longeur
                                        for k:=0 to niveau.tailley-1 do //5 blocs de hauteur
                                            begin
                                                niveau.lniveau[l][rangx][k]:=pattern[r][i][k];//le rang x du bloc est i+s*5 car on remplie 5 case du tableau a chaque tous de la boucle while
                                                niveau.lniveau[l][rangx][k].destRect.x:=(rangx)*50+niveau.lniveau[x][19][1].destRect.x+50;//on part du dernier bloc de l'ecran precedant (le 3 eme ecran a etre affiché) rt on ajoute (i+s*5)*50 sois 50 la largeur d'un bloc et (i+s*5)le rang du bloc
                                            end;
                                    end;     
                                s:=s+1;
                            end;                        
                    end;
            end;
        
end;
procedure proceduralGenEnemies(var enemies:Tenemies; var niveau:Tniveau); 
var i:integer;
begin
    for i:=0 to enemies.taille-1 do //pour chaque enemie
        begin
            if enemies.lEnemies[i].destRect.x<-1000 then //si l'enemie est hors de l'ecran
                begin
                    if not ((niveau.lniveau[enemies.lEnemies[i].l][0][0].destRect.x >-1000) and (niveau.lniveau[enemies.lEnemies[i].l][0][0].destRect.x<900)) then //si l'ecran de l'enemie est hors de l'ecran
                        initialisationEnemies(enemies.lEnemies[i],niveau); //on initialise l'enemie
                end;

        end;
end;
end.
