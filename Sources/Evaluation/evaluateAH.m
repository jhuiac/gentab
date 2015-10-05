function [confTons, confOctaves]=evaluateAH(filename, notesDet)
%evaluateAH.m
%
%   USAGE:   
%       [confTons, confOctaves]=evaluateAH(filename, notesDet)
%   ATTRIBUTS:    
%       confTons: Matrice de confusion des tons
%       confOctaves: Matrice de confusion des octaves
%   
%       filename: nom et chemin absolu du fichier o� sont stock�es les
%       valeurs attendues
%       notesDet:   notes d�tect�es par l'application
%    
%   DESCRIPTION:
%       Ce script evalue l'analyse harmonique des onsets en lisant les donn�es attendues dans
%       le  fichier expected.txt
%       N.B: Une note est compos� d'un ton et d'une octave
%
%   BUT:   
%       Fournir des indicateurs de la performances des algorithmes
%       d'analyse harmonique
%       Indicateurs:
%       *   Matrice de confusion 12x12 tons attendues vs. tons d�tect�es
%           (cette matrice ne tient pas compte des octaves d�tect�es)
%       *   Matrice de confusion 5x5 octaves attendues vs. octaves
%       d�tect�es
%       *   Histogramme des �carts entre le tons attendue et le ton d�tect�


%% V�rification sur l'argument filename
filename = strrep(filename, '\', '/');  % Conversion Win -> linux
% if filename(end) ~= '/'
%     filename = [filename '/'];
% end
[path, file, extension]=fileparts(filename);
if ~isdir(path)
    error(strcat('[ERREUR] Le dossier ', path, ' n''existe pas.'));
end

if ~exist(filename, 'file');
    error(strcat('[ERREUR] Le fichier ', filename, ' n''existe pas dans ', path));
end


% Ouverture du fichier
FID=fopen(filename, 'r');
if(FID==-1)
    error('Impossible d''ouvrir le fichier');
end


confTons = eye(12,12)*10;
confOctaves = zeros(5,5);

%% Lecture des donn�es attendues
tempo=str2num(fgets(FID)); %tempo
nbNotesExp=str2num(fgets(FID)); % Nombre de notes attendues

for k=1:nbNotesExp
   %Lecture d'une note 
end

%%   Affichage de la matrice de confusion des tons
disp('Matrice de confusion des tons');
rowNames = {'A ', 'A#', 'B ', 'C ', 'C#', 'D ', 'D#', 'E ', 'F ', 'F#', 'G ', 'G#'};
firstRow = '';
for k = 1:length(rowNames)
    firstRow = [firstRow, ' ', rowNames{k}];
end
disp(['    ', firstRow]);
for k = 1:length(rowNames)
    disp([rowNames{k}, '   ', num2str(confTons(k,:))]);
end

%% Affichage de la matrice de confusion des octaves
disp('Matrice de confusion des octaves');
disp(['    ', num2str(2:6)]);
for k = 2:6
    disp([num2str(k), '   ', num2str(confOctaves(k-1,:))]);
end

fclose(FID);

disp('All OK');

end