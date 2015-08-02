function [segments, bornes]=segmentation(x, sf, ind_onsets, Fs)
% segmentation.m
% 
%   USAGE: 
%       [segments, bornes]=segmentation(x, sf, ind_onsets, Fs)
%   ATTRIBUTS:
%       segments:      Liste des extraits du signal d'origine correspondant chacun 
%               � un segment (ou note jou�e).
%       bornes: indices dans le domaine temporel d'origine correspondant
%               aux bornes de chaque segment.
%
%       x:      signal audio d'origine
%       sf:     r�sultat de l'algorithme de flux spectral
%       ind_onsets: indices dans le domaine du flux spectral des onsets 
%               r�cup�r�s apr�s l'Onset Detection
%       Fs:     Fr�quence d'�chantillonnage
% 
%   Description:
%       Cette fonction construit la liste des diff�rentes notes jou�es et 
%       rep�r�es par l'algorithme d'Onset Detection. Ces notes se 
%       pr�sentent sous la formes de vecteurs de taille variable 
%       correspondant � des extrait du son d'origine (sans traitement).

%% D�but du script
disp('D�but de la segmentation');
FsSF=(length(sf)/(length(x)/Fs));   %Calcul le rapport de r�duction entre 
%le son d'origine et la sortie de l'algo de "spectral flux".
t_x=(0:1/Fs:(length(x)-1)/Fs)'; %Vecteur temps du signal d'origine


for i=[1:length(ind_onsets)]    %Pour chaque attaque d�tect�e,
    [val bornes(i, 1)]=min(abs(t_x-ind_onsets(i)/FsSF)); %On ajoute la valeur la plus proche de celle reconstitu�e via FsSF
end %a priori pas de vectorisation de cet algorithme possible


% La premi�re note se situe entre les bornes 1 et 2 car le premier segment 
% est n�c�ssairement un silence (entre le d�but et la premi�re attaque).
segment1=[x(bornes(1):bornes(2))]; 

segments={segment1};   % On initialise la liste de sortie avec la premi�re note

for i=[2:length(bornes)-1]
    segments=cat(1,segments,[x(bornes(i):bornes(i+1))]);    % On ajoute les segments � la liste.
end

%%%
% Cette boucle peut �tre ex�cut�e pour tester le bon fonctionnement de
% l'algorithme.
% Tous les segments sont jou�s les uns apr�s les autres.
% On doit retrouv� le morceau d'origine entrecoup� de petits silence entre
% chaque segment.

% for i=[1:length(segments)]
% sound(segments{i},Fs);
% end
disp('Fin de la segmentation');

end
%% Fin de la fonction