function [ tempo ] = determinationTempo( liste_notes_groupees, tempos_candidats )
%determinationTempo.m
%   USAGE:
%       [ tempo ] = determinationTempo( liste_notes_groupees, tempos_candidats )
%
%   ATTRIBUTS:
%       tempo: tempo du morceau en bpm normalis� au nombre pair le plus proche
%
%       liste_notes_groupees: liste de notes contenant leur duree et leur
%       population
%
%       tempos_candidats: dur�e des notes converties en bpm et tri�e dans
%       l'ordre croissant (apr�s conversion)
%
%   BUT:
%       Pour d�terminer le tempo, on compte le nombre total de note plus 
%       lente que la noire et le nombre de noires. On reprend la liste des 
%       �carts que l'on trie dans l'ordre ascendant (descendant) et on 
%       calcule la moyenne des �carts pour les noires (avec les deux 
%       valeurs donn�es pr�c�dement). On arrondi au nombre pair le plus
%       proche. C'est le tempo.
%   
%   R�SULTATS:
%       Bons r�sultats � 2 ou 4 bpm pr�s (acceptable). Faire plus de tests
%       TODO: /!\ Il faut prendre en compte le cas ou il n'y a pas de noires!


 pop_noire=sum(double(liste_notes_groupees(find(strcmp(liste_notes_groupees.DureeDeLaNote,'noire')),3)));
 pop_inf_noire=sum(double(liste_notes_groupees(find(strcmp(liste_notes_groupees.DureeDeLaNote,'noire'))+1:length(liste_notes_groupees),3)));
 tempo=mean(tempos_candidats(pop_inf_noire+1:pop_inf_noire+pop_noire)); %les tempos_candidats ne sont pas normalis�e
 tempo=2*round(tempo/2) %Arrondi par 2

end

