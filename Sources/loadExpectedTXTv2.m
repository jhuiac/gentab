function [notesExpected, rythmeExpected, tempo, FsSTFT]=loadExpectedTXT(filepath)
%   save2expectedTXT.m
%   USAGE: 
%       [notesExpected, rythmeExpected]=loadExpectedTXT(filename)
%   ATTRIBUTS:
%       filename: nom du fichier � lire, incluant le chemin relatif
%       notesExpected:
%           Liste des notes reconnues. Format 'note|#/(espace)|octave' sans
%           s�parateur
%       rythmeExpected:
%           Liste des dur�es de note reconnues. Format: cell array
%           verticale contenant le "nom" des dur�es de note.
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

fileLength=fread(FID, 1, '*double');
notesExpected=fread(FID, fileLength*3, '*char');
notesExpected=reshape(notesExpected, [], 3);

rythmeExp=fread(FID, inf, '*char');

rythmeExpected={};
curChar='';
mot='';
for (i=1:length(rythmeExp))
    curChar=rythmeExp(i);
    if(curChar=='\')
        rythmeExpected={rythmeExpected{:} mot}'; 
        mot='';
    else
        mot=[mot curChar];
    end
end

fclose(FID);
end