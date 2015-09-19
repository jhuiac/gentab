function [] = save2expectedTXT(filename, viIndexOnset, viNotes, viRythme, iTempo,dFsSTFT)
%   save2expectedTXT.m
%   USAGE: 
%       [] = save2expectedTXT(filename, viNotes, rythmen, iTempo)
%   ATTRIBUTS:
%       filename: nom du fichier � g�n�rer, incluant le chemin relatif
%       viIndexOnset: indices o� les onsets (offsets) sont d�tect�s dans la
%       base de temp FsSTFT.
%       viNotes: liste des viNotes effectivement jou�e respectant le format A#3
%           (note, di�se/espace, octave). Une note par ligne.
%       viRythme: liste des dur�e de viNotes au format vecteur d'entier (ou double).
%           La valeur de dur�e de la note correspond � l'indice dans le
%           tableau tab_nom_duree_viNotes g�n�r� � l d�composition rythmique
%       iTempo: iTempo moyen � la noire pour tout le morceau.
%       dFsSTFT: Temps d'�chantillonnage apr�s transformation par STFT
%
%   BUT:
%       �crire dans un fichier .txt les valeurs attendues � la fin des
%       calculs pour am�liorer l'�valuation des tests. Compl�mentaire avec
%       loadExpectedTXT().

if(nargin~=6)
    error('Invalid input argument');
end

fileLength=length(viIndexOnset);

%Cr�e le ficheir s'il n'existe pas
FID=fopen(filename, 'a');
if(FID==-1)
    error('Le chemin ou le nom du fichier est incorrect');
end

% Vide le fichier
FID=fopen(filename, 'w');
fclose(FID);

% Ouvre le fichier en mode append
FID=fopen(filename, 'a');

% �criture du nombre de note en ent�te du fichier
fprintf(FID, '%d notes\n', fileLength);

% �criture du iTempo en ent�te du fichier
fprintf(FID, 'Tempo: %d bmp\n', int16(iTempo));

% �criture de la fr�quence d'�chantillonage en ent�te du fichier
fprintf(FID, 'FsSTFT: %s Hz\n', num2str(double(dFsSTFT)));

% retour_char = repmat('\n', size(viNotes, 1), 1)
% [viNotes retour_char];
for(i = 1:fileLength)
    fprintf(FID, '%s\t%d\t%d\n',int16(viNotes(i,:)), int16(viRythme(i)), viIndexOnset(i));
   % fprintf(FID, [rythme{i} '\n'], '*char');
end

fclose(FID);
end