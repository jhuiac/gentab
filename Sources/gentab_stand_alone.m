%%%
% gentab_stand_alone.m
% Ce script charge un fichier audio et ex�cute tout l'algorithme, sans
% �valuation, sans affichage, avec g�n�ration du fichier de sortie. 

close all
clc
beep off

addpath(genpath('../GenTab/'))
% [~, cheminFichier, ~]=getConfig();

%% Chargement des donn�es
[x,Fs]=audioread(audioFilename);
x=sum(x,2);  

OnsetDetection;
[segments, bornes]=segmentation(x, length(oss), sampleIndexOnsets, Fs, sampleIndexOffsets(length(sampleIndexOffsets)));

%% Analyse rythmique
[durees, tempo, silences, sampleIndexOffsets] = AnalyseRythmique(oss, bornes, FsOSS, Fs, sampleIndexOnsets, sampleIndexOffsets, 0);
correctionDureeNotes;

%% Analyse harmonique
AnalyseHarmonique;

%% Mise en forme des r�sultats
notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(oss), silences, dureesCorrigees, notesJouees);  

%% �valuation des r�sultats
out = strcat(exportDir, '/', fileName, '.mid');
generationMidi;