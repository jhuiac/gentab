function [notesExpected, rythmeExpected, indexOnsets, tempoExpected, FsSTFT]=loadExpectedTXT(filepath)
%   save2expectedTXT.m
%   USAGE: 
%           [notesExpected, rythmeExpected, indexOnsets, tempoExpected, FsSTFT]=loadExpectedTXT(filepath)
%   ATTRIBUTS:
%       filename: nom du fichier � lire, incluant le chemin relatif
%       notesExpected:
%           Liste des notes reconnues. Format 'note|#/(espace)|octave' sans
%           s�parateur
%       rythmeExpected:
%           Liste des dur�es de note reconnues. Format: cell array
%           verticale contenant le "nom" des dur�es de note.
%       indexOnsets: indices o� les onsets (offsets) sont d�tect�s dans la
%       base de temp FsSTFT.
%       tempoExpected: Tempo moyen � la noire pour tout le morceau.
%       FsSTFT: Temps d'�chantillonnage apr�s transformation par STFT
%
%   BUT:
%       Lire dans un fichier .txt les valeurs attendues � la fin des
%       calculs pour am�liorer l'�valuation des tests. Compl�mentaire avec
%       save2expectedTXT().

%% V�rification sur l'argument filepath
filepath = strrep(filepath, '\', '/');  % Conversion Win -> linux
if filepath(end) ~= '/'
    filepath = [filepath '/'];
end
pattern = '/expected.txt';
if ~isdir(filepath)
    error(strcat('[ERREUR] Le dossier ', filepath, ' n''existe pas.'));
end
filename = strcat(filepath, pattern);
if ~exist(filename, 'file');
    error(strcat('[ERREUR] Le fichier ', pattern, ' n''existe pas dans ', filepath));
end

FID=fopen(filename, 'r');
if(FID==-1)
    error('Impossible d''ouvrir le fichier');
end

fileLength=fscanf(FID, '%d notes');
tempoExpected = fscanf(FID, 'Tempo: %d bmp');
fgets(FID);
line = fgets(FID);
FsSTFT = sscanf(line, 'FsSTFT: %f Hz');

% notesExpected=fread(FID, fileLength*3, '*char');
% notesExpected=reshape(notesExpected, [], 3);
% 
% rythmeExp=fread(FID, inf, '*char');

notesExpected=[];
rythmeExpected=[];
indexOnsets=[];
% mot='';
for (i=1:fileLength)
    %[sCurrentNote, duree, index]=fscanf(FID, '%s\t%d\t%d');
    line = fgets(FID);
    if length(line)>7
        notesExpected = [notesExpected;line(1:3)];
        [result]=str2num(line(4:end));
        rythmeExpected = [rythmeExpected;result(1)];
        indexOnsets = [indexOnsets;result(2)];
    end
%     curChar=rythmeExp(i);
%     if(curChar=='\')
%         rythmeExpected={rythmeExpected{:} mot}'; 
%         mot='';
%     else
%         mot=[mot curChar];
%     end
end

fclose(FID);
end