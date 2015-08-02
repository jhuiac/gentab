function [ peaks_out ] = OD_postTraitement( peaks, FsSFFT )
%OD_postTraitement.m
%   USAGE:
%       [ peaks_out ] = OD_postTraitement( peaks, Fs )
%
%   ATTRIBUTS:
%       peaks: vecteur dans le domaine du temps de la sfft � 1 pour un
%       onset (offset d�tect�) 0 sinon;
%       FsSFFT: Fr�quence d'�chantillonnage dans le domaine du temps de la sfft
%   TODO:
%       � d�velopper et terminer

%%  V�rification de l'�cart minimal respect�
%Si deux onsets sont plus proche que ecart_minimal, alors on supprime le
%deuxi�me.
ecart_minimal= round(60/240*FsSFFT);   %ecart correspondant � 240 bpm



end

