function [ notesNormeesModifiees ] = correctionDoubleCrochePointee( notesNormees, classeDoubleCroche, tempo, ecarts, Fs )
% correctionDoubleCrochePointee.m
%   USAGE:
%       [ notesNormeesModifiees ] = correctionDoubleCrochePointee( notesNormees, classeDoubleCroche, tempo, ecarts )
%   ATTRIBUTS:
%       notesNormeesModifiees: ce vecteur doit remplacer 'notesNormees'
%       
%       notesNormees: Ce vecteur contient les notes sous forme de "tempos
%       normalis�s" par octave dans le domaines 4:0.5:9
%
%       classeDoubleCroche: classe des double-croches calcul�e a priori
%       dans le domaine 4:0.5:9
%
%       tempo: tempo final arrondi au nombre pair le plus proche
%
%       ecarts: vecteurs des �carts entre les bornes des segments (en nb
%       d'�chantillons).
%
%       Fs: fr�quence d'�chantillonnage
%
%   BUT:
%       Les doubles croches point�es sont rares... On consid�re donc que 
%       pour une mesure int�rm�diaire entre une double croche et une 
%       double croche point�e, il y a une plus grande probabilit� qu'il 
%       s'agisse d'une double croche. On revoit donc l'estimation de la 
%       classe im�diatement inf�rieure � celle des doubles croches.
%    
%   R�SULTATS:
%       N'a pas prouv� son efficacit�...


    indNotesSuspectes=find(notesNormees==classeDoubleCroche-0.5);
    
    tempoDoubleCroche=4*tempo;
    tempoDoubleCrochePointee=tempo*2^classeDoubleCroche/2^(classeDoubleCroche-1.5);
    
    %On refait le calcul des tempos, �a ne coute pas cher
    tempos=(ecarts./Fs);
    tempos=((60)./tempos);
    notesNormeesModifiees=notesNormees;
    notesNormeesModifiees(indNotesSuspectes(find(tempos(indNotesSuspectes)>(tempoDoubleCroche/2+tempoDoubleCrochePointee/2))))=classeDoubleCroche;

end

