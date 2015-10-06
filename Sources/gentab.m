%%%
% gentab.m
% Ce script teste tous les composants de l'algorithme � partir 
% d'un signal audio qu'il charge lui m�me
%

clear all
close all
clc
beep off

addpath(genpath('../Sources'))

%% Chargement des donn�es
disp('Fichier audio en entr�e?');
disp('1: essaiRomain');
disp('2: Blue Orchid (bends) - 30s');
disp('3: essaiRomain - 12s');
disp('4: Sortie');

choixEchantillon=input('Choix? '); %Attend une action utilisateur
clc
switch choixEchantillon
    case 1
        disp('essaiRomain');
        % On selectionne Les 8 premi�res secondes de la chanson Day Tripper des
        % Beatles
        % Dans cet �chantillon, de la guitare est jou�e en solo
        audioFilename='essaiRomain.wav';
        [x,Fs]=audioread(audioFilename);
        x=x(1:Fs*12,1);
    case 2
        disp('Blue Orchid (bends)');
        %O� un echantillon g�n�r� logiciellement contenant de la guitare et des
        %dur�es de notes vari�es.
        audioFilename='Echantillon_34SecondesNotesVariees.wav';
        [x,Fs]=audioread(audioFilename);
        x=x(1:Fs*30,1);
    case 3
        disp('essaiRomain');
        %O� un echantillon (12s) g�n�r� logiciellement contenant de la guitare et des
        %silences (croches et noires et � la fin un silence d'une ronde et demie
        audioFilename='essaiRomain.wav';
        [x,Fs]=audioread(audioFilename);
        x=x(1:Fs*12,1);
    
    case 4
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
disp('SEG: Segmentation + OD');
disp('AH: Analyse harmonique (Identification des notes jou�es) + OD + SEG');
disp('AR: Analyse Rythmique (D�termination de la composition rythmique) + OD + SEG');
disp('ALL: Tous les algorithmes pr�c�dents');
disp('OUT: Sortie');

OD='OD';
SEG='SEG';
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
    AnalyseRythmique;
end
    
%% Analyse harmonique
if(strcmp(choixAlgo, AH) | strcmp(choixAlgo, ALL));
    AnalyseHarmonique;
end

if(strcmp(choixAlgo, OUT))
    clc
    close all
    clear all
end
clear OD SEG AH AR ALL OUT;