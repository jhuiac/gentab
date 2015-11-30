%%%
% gentab.m
% Ce script teste tous les composants de l'algorithme � partir 
% d'un signal audio qu'il charge lui m�me
%

% clear all
close all
clc
beep off

addpath(genpath('../Sources/'))
[cheminGP, cheminFichier, cheminEvaluation]=getConfig();
rmpath(cheminEvaluation)

%% Chargement des donn�es
disp('Fichier audio en entr�e?');
disp('1:	DayTripper - 8s');
disp('2:	Blue Orchid (bends) - 30s');
disp('3:	nosurprises - 26s');
disp('4:	Aller Retour Diatonique - 8s');
disp('5:	Heart & Soul - 16s');
disp('6:	Seven Nation Army - 30s');
disp('7:	Hardest Button to Button - 35s');
disp('8:	Johnny B Good - 47s');
disp('9:	Voodoo Child - 40s');
disp('10:	Kashmir - 33s');
disp('11:	Plugin Baby - 16s');
disp('12:	Time is Running Out - 24s');
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
    case 10
        disp('Kashmir');
        audioFilename='Kashmir.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x,2);
    case 11
        disp('Plugin Baby');
        audioFilename='Plugin_Baby.wav';
        [x,Fs]=audioread(audioFilename);
        x=sum(x,2);
    case 12
        disp('Time is Running Out');
        audioFilename='Time_Running_Out.wav';
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
disp('ALLtemp: Tous les algorithmes pr�c�dents. Le tempo vous sera demand� au lieu d''�tre d�termin�');
disp('OUT: Sortie');

OD='OD';
AH='AH';
AR='AR';
ALL='ALL';
ALLtemp='ALLtemp';
OUT='OUT';
choixAlgo=input('Choix? ');

clc

%% Onset Detection
if(~strcmp(choixAlgo, OUT)) % Dans tout les cas sauf une sortie
        OnsetDetection;
end
    
%% Segmentation
if(~strcmp(choixAlgo, OUT) & ~strcmp(choixAlgo, OD)) % Dans tout les cas sauf une sortie ou OD
        [segments, bornes]=segmentation(x, length(oss), sampleIndexOnsets, Fs);
end

%% Analyse rythmique
if(strcmp(choixAlgo, AR) | strcmp(choixAlgo, ALL));

    [durees, tempo] = AnalyseRythmique(oss, bornes, FsOSS, Fs, 0);
    correctionDureeNotes;
%     dureesCorrigees = durees;
elseif strcmp(choixAlgo, ALLtemp)
    tempo = input('Tempo? ');
    [durees] = AnalyseRythmique(oss, bornes, FsOSS, Fs, 0, tempo);
    correctionDureeNotes;
%     dureesCorrigees=durees;
end
    
%% Analyse harmonique
if(strcmp(choixAlgo, AH) | strcmp(choixAlgo, ALL)| strcmp(choixAlgo, ALLtemp));
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
    notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(oss));
    tempo = 0;
elseif strcmp(choixAlgo, AH)
    notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(oss), notesJouee);
    tempo = 0;
elseif strcmp(choixAlgo, AR)
    notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(oss), dureesCorrigees);
elseif strcmp(choixAlgo, ALL) | strcmp(choixAlgo, ALLtemp)
    notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(oss), dureesCorrigees, notesJouee);  
end

%% �valuation des r�sultats

[~, file, ~]=fileparts(audioFilename);
filename = strcat(file, '/expected.txt');
if strcmp(choixAlgo, OD)
    [txFDetection, txDetectionManquante, txReussite, ecartMoyen] = evaluateOD(filename, notesDet)
elseif strcmp(choixAlgo, AH)
    [txFDetection, txDetectionManquante, txReussite, ecartMoyen] = evaluateOD(filename, notesDet)
    [confTons, confOctaves]=evaluateAH(filename, notesDet);
elseif strcmp(choixAlgo, AR)
    [txFDetection, txDetectionManquante, txReussite, ecartMoyen] = evaluateOD(filename, notesDet)
    [confDurees]=evaluateAR(filename, notesDet, tempo, 0);
elseif strcmp(choixAlgo, ALL) | strcmp(choixAlgo, ALLtemp)
    [txFDetection, txDetectionManquante, txReussite, ecartMoyen] = evaluateOD(filename, notesDet)
    [confTons, confOctaves]=evaluateAH(filename, notesDet);
    [confDurees]=evaluateAR(filename, notesDet, tempo, 0);

    %% Generation et ouverture du Fichier MIDI avec Guitar Pro
    o='o'; O='O'; n='n'; N='N';
    choix=input('G�n�rer un fichier MIDI (o/n)? ');
    if strcmp(choix, 'o') || strcmp(choix, 'O')
        generationMidi;
        os=computer;
        s2='MACI64';
        if strcmp(os,s2)==1
        lancementMIDI = strcat('open -a "', cheminGP, '" "', cheminFichier, file,'/',file, '.mid"')
        else  
        lancementMIDI = strcat('"', cheminGP, '" "', cheminFichier, file, '\out.mid"');
        end
        system(lancementMIDI);
    end
end
clear choix choixAlgo OD AR AH ALL filename o O n N;