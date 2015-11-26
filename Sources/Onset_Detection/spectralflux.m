function [sf] = spectralflux(stft)
% spectralflux.m
% 
%   USAGE: 
%       [sf] = spectralflux (stft)
%   ATTRIBUTS:
%       stft:   Sortie de la stft (doubles complexes) de la forme stft(f,t) ou f est le domaine spectral, t le domaine temporel
%       sf:     R�sultat de l'algorithme de flux spectral
% 
%   Description:
%       Cette fonction construit la liste des diff�rentes notes jou�es et 
%       rep�r�es par l'algorithme d'Onset Detection. Ces notes se 
%       pr�sentent sous la formes de vecteurs de taille variable 
%       correspondant � des extrait du son d'origine (sans traitement).

% Coefficients d'un filtre de d�riv�e.
 a=1;b=[1 -1];
 
 %Premier algo possible, fonctionne bien mais pas sf
 %Meilleur pour Day Tripper
stft=log10(abs(stft)+1); % Passage en �chelle logarithmique pour minimiser les �carts
%  sfLogSum=sum(sfLog);    % Somme de toutes les valeurs � un instant t. Donne un vecteur en fonction du temps.

%Algo de sf
sf=filter(b, a, abs(stft)); % d�riv�e
%sf=diff(abs(stft));
% sf=(sf+abs(sf))/2;  % Passage des pics n�gatifs en pics positifs
%  semble pas utile car on a que des valeurs positives
sf=sum(sf)';

%sf=zscore(sf); % Normalisation des valeurs

end
