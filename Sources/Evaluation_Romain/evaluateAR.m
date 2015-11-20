function [confDurees, ecartTempo]=evaluateAR(filename, noteDet, tempo, display)
%evaluateAR.m
%
%   USAGE:   
%       [confDurees]=evaluateAR(filename, noteDet, tempo, display)
%   ATTRIBUTS:    
%       confDurees: Matrice de confusion des dur�es de notes
%       ecartTempo: �cart en % du tempo
%
%       filename: nom et chemin absolu du fichier o� sont stock�es les
%       valeurs attendues
%       noteDet:   notes d�tect�es par l'application
%       tempo: tempo d�tect� par l'application
%       display: affiche une un histogramme
%   DESCRIPTION:
%       Ce script evalue l'analyse rythmique des onsets en lisant les donn�es attendues dans
%       le  fichier expected.txt
%       N.B: Une note est compos� d'un ton et d'une octave
%
%   BUT:   
%       Fournir des indicateurs de la performances des algorithmes
%       d'analyse harmonique
%       Indicateurs:
%       *   Matrice de confusion 16x16 dur�es attendues vs. dur�es d�tect�es
%       *   Histogramme des �carts entre la dur�e attendue et la dur�e
%       d�tect�e
%       * �cart en % du tempo

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


confDurees = zeros(16,16);

%% Lecture des donn�es attendues
tempoExp=str2num(fgets(FID)); %tempo
nbNotesExp=str2num(fgets(FID)); % Nombre de notes attendues

for k=1:nbNotesExp
   %Lecture d'une note
   line = fgets(FID);
   entiers = sscanf(line, '%d');
   onset = entiers(1);  %onset attendu
   duree = entiers(2);  % dur�e attendue
   
   characteres = sscanf(line, '%c');
   octave = str2num(characteres(end-1)); % octave attendue
   
   rowNames = {'A ', 'A#', 'B ', 'C ', 'C#', 'D ', 'D#', 'E ', 'F ', 'F#', 'G ', 'G#'};   % temp
   for j=1:12
       if strcmp(rowNames{j}, characteres(end-3:end-2)) ~= 0
          ton=j; % note attendue
       end
   end
   noteExp(k)=Note(onset, duree, ton, octave);
   onsetsExp(k)=onset;
end

if nbNotesExp~=length(noteExp)
    error('Erreur de lecture: le fichier ne contient pas le nombre de notes indiqu�es');
end

%% Construction des matrices de confusions
indiceDet = 0;
indiceExp = 0;
detInExp = 0;
expInDet = 0;

for k=1:length(noteDet)
    onsetsDet(k)=noteDet(k).indice;
end

while indiceDet < length(noteDet)
    if indiceDet < length(noteDet)
        indiceDet=indiceDet+1;
    end   
    
    newDetInExp = findClosest(onsetsExp, noteDet(indiceDet).indice);
    indiceExp = newDetInExp;
    newExpInDet = findClosest(onsetsDet, noteExp(indiceExp).indice);
   
    if newExpInDet-newDetInExp == expInDet-detInExp && newExpInDet> expInDet
        confDurees(noteDet(indiceDet).duree,noteExp(indiceExp).duree) = confDurees(noteDet(indiceDet).duree,noteExp(indiceExp).duree) + 1;
    end
    detInExp = newDetInExp;
    expInDet = newExpInDet;
end

%%   Affichage de la matrice de confusion des durees
disp('Matrice de confusion des durees');
disp(['    ', num2str(1:length(confDurees))]);
for k = 1:16
    disp([num2str(k), '   ', num2str(confDurees(k,:))]);
end

%% Affichage de l'histogramme des �carts
toeplitz(-15:15);
toeplitzMat = ans(1:16,16:end);
for k=-15:15
    totalAttendu = sum(confDurees');
    histogramme(k+16)=sum(confDurees(find(toeplitzMat==k)));
end

if display
    figure
    bar((-15:15),histogramme);
    axis([-15 15 0 max(histogramme)+1]);    
end

ecartTempo = (tempoExp-tempo)/tempoExp*100;
disp('�cart du tempo:');
disp([num2str(ecartTempo) ' %']);
if(ecartTempo ~= 0)
    disp(['Tempo attendu: ' num2str(tempoExp) ' au lieu de ' num2str(tempo)]);
end

disp(['Taux de succ�s dur�es: ' num2str(sum(diag(confDurees))/sum(sum(confDurees))*100) '%']);
fclose(FID);
end