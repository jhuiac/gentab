% GENE_determination_notes.m
%   Les notes sont mal d�tect�es pour celles plus graves que le E (corde de D - 2�me case)
%   TODO:
%       -R�soudre le probl�eme des notes graves.
%           -Tester de diff�rentes fa�on cet algo
%       -Rechercher et mettre en place une solution pour d�tecter plusieurs
%       notes � la fois.
%
disp('D�but identification des notes');
for segment= [1:length(L)]
    notes_jouee(segment,:)=determination_note_segment_octave(L{segment} , Fs);
end
disp('Fin identification des notes');
notes_jouee
%% Pour le morceau Echantillon....wav on reconnait:
% Le segment 2 (B), 3 (D), 4 (F) noires
% Le segment 5 (A), 6 (B), 7 (A), etc... croches
% Pas le segment 13 (B au lieu de E)
% Le segment 14 (G)*, 15 (A) , 16 (C), 17 (D), 18 (E)




%*(avec padded 2^15)
