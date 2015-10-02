function [] = save2expectedTXT(filename, notes, rythme)
%   save2expectedTXT.m
%   USAGE: 
%       [] = save2expectedTXT(filename, notes, rythme)
%   ATTRIBUTS:
%       filename: nom du fichier � g�n�rer, incluant le chemin relatif
%       notes: liste des notes effectivement jou�e respectant le format A#3
%           (note, di�se/espace, octave). Une note par ligne.
%       rythme: liste des dur�e de notes au format celle array. Sous forme
%           de colonne. Le nom de dur�e de note sont les m�mes que dans
%           tabNomDureeNotes g�n�r� � l d�composition rythmique
%   BUT:
%       �crire dans un fichier .txt les valeurs attendues � la fin des
%       calculs pour am�liorer l'�valuation des tests. Compl�mentaire avec
%       loadExpectedTXT().

if(nargin~=3)
    error('Invalid input argument');
end

if(length(notes)~=length(rythme))
    error('notes et rythme doivent avoir le m�me nombre d''entr�es');
end

fileLength=length(notes);

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
fwrite(FID, fileLength, '*double');
fwrite(FID, notes, '*char');

for(i = 1:fileLength)
    fwrite(FID, [rythme{i} '\'], '*char');
end

fclose(FID);
end