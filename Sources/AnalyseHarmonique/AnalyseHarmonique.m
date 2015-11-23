% GENEDeterminationNotes.m
%   DESCRIPTION:
%       Script d'ex�cution de tous les algos en rapport avec la d�tection
%       des notes. Doit fournir en sortie, la liste des notes jou�es,
%       segment par segment, incluant l'octave de la note.
disp('D�but identification des notes');
for index= [1:length(segments)]
    notesJouee(index,:)=determinationNoteSegmentOctave_Harmonic_Product_Spectrum(segments{index} , Fs);
end
disp('Fin identification des notes');

%% Pour le morceau Echantillon....wav on reconnait:
% Le segment 2 (B), 3 (D), 4 (F) noires
% Le segment 5 (A), 6 (B), 7 (A), etc... croches
% Pas le segment 13 (B au lieu de E)
% Le segment 14 (G)*, 15 (A) , 16 (C), 17 (D), 18 (E)




%*(avec padded 2^15)
