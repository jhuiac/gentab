function [ notes_normees_modifiees ] = correction_double_croche_pointee( notes_normees, classe_double_croche, tempo, ecarts, Fs )
% correction_double_croche_pointee.m
%   USAGE:
%       [ notes_normees_modifiees ] = correction_double_croche_pointee( notes_normees, classe_double_croche, tempo, ecarts )
%   ATTRIBUTS:
%       notes_normees_modifiees: ce vecteur doit remplacer 'notes_normees'
%       
%       notes_normees: Ce vecteur contient les notes sous forme de "tempos
%       normalis�s" par octave dans le domaines 4:0.5:9
%
%       classe_double_croche: classe des double-croches calcul�e a priori
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
%       Semble fonctionner mais m�rite beaucoup plus de tests


    ind_notes_suspectes=find(notes_normees==classe_double_croche-0.5);
    tempo_double_croche=4*tempo;
    tempo_double_croche_pointee=tempo*2^classe_double_croche/2^(classe_double_croche-1.5);
    
    %On refait le calcul des tempos, �a ne coute pas cher
    tempos=(ecarts(2:length(ecarts))./Fs);
    tempos=((60)./tempos);
    notes_normees_modifiees=notes_normees;
    notes_normees_modifiees(ind_notes_suspectes(find(tempos(ind_notes_suspectes)>(tempo_double_croche/2+tempo_double_croche_pointee/2))))=classe_double_croche;

end

