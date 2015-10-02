function [ peaksOut ] = ODPostTraitement( peaks, FsSFFT )
%ODPostTraitement.m
%   USAGE:
%       [ peaksOut ] = ODPostTraitement( peaks, Fs )
%
%   ATTRIBUTS:
%       peaks: vecteur dans le domaine du temps de la sfft � 1 pour un
%       onset (offset d�tect�) 0 sinon;
%       FsSFFT: Fr�quence d'�chantillonnage dans le domaine du temps de la sfft
%   TODO:
%       � d�velopper et terminer

%%  V�rification de l'�cart minimal respect�
%Si deux onsets sont plus proche que ecartMinimal, alors on supprime le
%deuxi�me.
ecartMinimal= round(60/240*FsSFFT);   %ecart correspondant � 240 bpm



end

