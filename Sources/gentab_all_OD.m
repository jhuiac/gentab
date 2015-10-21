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


%% Pr�traitement
% TODO:
%   Int�grer ici des traitements sur le signal qui doivent �tre ex�cut�s
%   avant toute op�rations.

%% �x�cution
%   R�qu�te utilisateur et ex�cution de tout o� partie de l'algorithme


disp('OD: Onset Detection des fichiers audios');
disp('OUT: Sortie');

OD='OD';

OUT='OUT';
choixAlgo=input('Choix? ');

clc

%% Onset Detection
if(~strcmp(choixAlgo, OUT)) % Dans tout les cas sauf une sortie
        audioFilename='heart-and-soul-tux.wav';
        [x,Fs]=audioread(audioFilename);
        x=x(:,1);
        OnsetDetection;
        title(audioFilename);
        audioFilename='ar-diatonique-tux.wav';
        [x,Fs]=audioread(audioFilename);
        x=x(:,1);
        OnsetDetection;
        title(audioFilename);
        audioFilename='DayTripper.wav';
        [x,Fs]=audioread(audioFilename);
        x=x(1:Fs*8,1);
        OnsetDetection; 
        title(audioFilename);
        audioFilename='BlueOrchidSansDeadNoteAvecBend.wav';
        [x,Fs]=audioread(audioFilename);
        x=x(1:Fs*30,1);
        OnsetDetection; 
        title(audioFilename); 
end


if(strcmp(choixAlgo, OUT))
    clc
    close all
    clear all
end
clear OD OUT;

