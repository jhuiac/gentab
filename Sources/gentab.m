%%%
% gentab.m
% Ce script teste tous les composants de l'algorithme � partir 
% d'un signal audio qu'il charge lui m�me
%

close all
clc
beep off

addpath(genpath('../Sources/'))

%% Chargement des donn�es
disp('Fichier audio en entr�e?');
disp('1: DayTripper - 8s');
disp('2: Blue Orchid (bends) - 30s');
disp('3: nosurprises - 26s');
disp('4: Aller Retour Diatonique - 8s');
disp('5: Heart & Soul - 16s');
disp('6: Seven Nation Army - 30s');
disp('7: Hardest Button to Button - 35s');
disp('8: Johnny B Good - 47s');
disp('9: Voodoo Child - 40s');
disp('0: Sortie');

choixEchantillon=input('Choix? '); %Attend une action utilisateur
clc
switch choixEchantillon
    case 1
        disp('DayTripper - 8s');
        % On selectionne Les 8 premi�res secondes de la chanson Day Tripper des
        % Beatles
        % Dans cet �chantillon, de la guitare est jou�e en solo
        audioFilename='DayTripper.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x(1:Fs*8,:),2);
    case 2
        disp('Blue Orchid (bends)');
        %O� un echantillon g�n�r� logiciellement contenant de la guitare et des
        %dur�es de notes vari�es.
        audioFilename='BlueOrchidSansDeadNoteAvecBend.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x(1:Fs*30,:),2);
    case 3
        disp('nosurprises');
        audioFilename='nosurprises.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x,2);
    case 4
        disp('A/R diatonique');
        audioFilename = 'ar-diatonique-tux.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x,2); 
    case 5
        disp('Heart & Soul');
        audioFilename='heart-and-soul-tux.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x,2); 
    case 6
        disp('Seven Nation Army');
        audioFilename='seven-nation-army.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x,2);  
    case 7
        disp('Hardest Button to Button');
        audioFilename='hardest-button.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x,2); 
    case 8
        disp('Johnny B Good');
        audioFilename='Johnny_B_Good.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x,2); 
    case 9
        disp('Voodoo Child');
        audioFilename='Voodoo_Child.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x,2); 
    case 0
        clc
        clear all;
        break;
        
    otherwise
    disp('Erreur');
end

clear choixEchantillon;

%% Pr�traitement
% TODO:
%   Int�grer ici des traitements sur le signal qui doivent �tre ex�cut�s
%   avant toute op�rations.

%% �x�cution
%   R�qu�te utilisateur et ex�cution de tout o� partie de l'algorithme

disp('Algo � ex�cuter?');
disp('OD: Onset Detection');
disp('AH: Analyse harmonique (Identification des notes jou�es) + OD + SEG');
disp('AR: Analyse Rythmique (D�termination de la composition rythmique) + OD + SEG');
disp('ALL: Tous les algorithmes pr�c�dents');
disp('OUT: Sortie');

OD='OD';
AH='AH';
AR='AR';
ALL='ALL';
OUT='OUT';
choixAlgo=input('Choix? ');

clc

%% Onset Detection
if(~strcmp(choixAlgo, OUT)) % Dans tout les cas sauf une sortie
        OnsetDetection;
end
    
%% Segmentation
if(~strcmp(choixAlgo, OUT) & ~strcmp(choixAlgo, OD)) % Dans tout les cas sauf une sortie ou OD
        [segments, bornes]=segmentation(x, length(sf), sampleIndexOnsets, Fs);
end

%% Analyse rythmique
if(strcmp(choixAlgo, AR) | strcmp(choixAlgo, ALL));
    [durees, tempo] = AnalyseRythmique(sf, bornes, FsSF, Fs, 0);
end
    
%% Analyse harmonique
if(strcmp(choixAlgo, AH) | strcmp(choixAlgo, ALL));
    AnalyseHarmonique;
end
%%
if(strcmp(choixAlgo, OUT))
    clc
    close all
    clear all
end


%% Mise en forme des r�sultats
if strcmp(choixAlgo, OD)
    notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(sf));
    tempo = 0;
elseif strcmp(choixAlgo, AH)
    notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(sf), notesJouee);
    tempo = 0;
elseif strcmp(choixAlgo, AR)
    notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(sf), durees);
elseif strcmp(choixAlgo, ALL)
    notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(sf), durees, notesJouee);  
end


%% �valuation des r�sultats

[~, file, ~]=fileparts(audioFilename);
filename = strcat(file, '/expected.txt');
[txFDetection, txDetectionManquante, txReussite, ecartMoyen] = evaluateOD(filename, notesDet)
[confTons, confOctaves]=evaluateAH(filename, notesDet);
[confDurees]=evaluateAR(filename, notesDet, tempo, 0);
txReussite

%% Generation et ouverture du Fichier MIDI avec Guitar Pro
generationMidi

cheminGP = 'start "" "C:\Program Files (x86)\Guitar Pro 5\GP5.exe" ';
cheminFichier = strcat(pwd, '\', out);
lancementMIDI = strcat([CheminGP cheminFichier]);
dos(lancementMIDI);