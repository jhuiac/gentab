function [ note ] = determination_note_segment_octave( segment , Fs)
%determination_note_segment.m
%   USAGE:
%       [ note ] = determination_note_segment_octave( segment , Fs)
%


%% Calcul de la fft sur le segment
if(length(segment)<2^19)
    seg_fft_win=fft(segment.*blackman(length(segment)), 2^15);  %Permet d'assurer une pr�cision suffisante
else
    seg_fft_win=fft(segment.*blackman(length(segment)));
end
seg_fft_win_replie=seg_fft_win(1:(length(seg_fft_win)/2))+seg_fft_win(length(seg_fft_win):-1:(length(seg_fft_win)/2+1));
seg_fft_win_replie=abs(seg_fft_win_replie);

%% g�n�ration d'un filtre pour la pond�ration de chaque note
tableNotes=generateTableNotes(false);
filtre=generateGaussian(length(abs(seg_fft_win_replie)), Fs, tableNotes);

%Vecteur de la fr�quence pour cette fft sp�cifiquement
f=((Fs/(length(seg_fft_win)):(Fs/(length(seg_fft_win))):Fs/2));

%Visualisation
% plot(f, [seg_fft_win_replie filtre])


%% Projection de la fft sur le filtre g�n�r�. Mets en �vidence les pics �
% des fr�quences de note normalis�es.
tableNotes=generateTableNotes(false);
bornes_octaves=sort([tableNotes(1,:,2) tableNotes(1,end,4)])';
ind_bornes_octaves=findClosest(f, bornes_octaves);
projection_win= filtre.*repmat(seg_fft_win_replie, 1, 12);

for i=1:length(ind_bornes_octaves)-1
    sum_projection_win(:,i)=sum(projection_win(ind_bornes_octaves(i):ind_bornes_octaves(i+1),:),1)';
end
%sum_projection_win=sum(projection_win,1)';
% figure
% mesh(sum_projection_win');
% set(gca, 'XTick',1:12, 'XTickLabel',{'E ' 'F ' 'F#' 'G ' 'G#' 'A ' 'A#' 'B ' 'C ' 'C#' 'D ' 'D#'})

%S�lection du r�sultat maximum de cette projection.

[valMax indice_note_jouee]=max(sum(sum_projection_win,2)); %N'est valable que pour 1 note jou�e � la fois
projection_deroulee=sum_projection_win(:);
ind_compoTonale=find(projection_deroulee>(mean(projection_deroulee)+std(projection_deroulee)));
octaveFondamentale=floor((ind_compoTonale(1)+3)/12)+2;    %Cette mise � l'�chelle est bas�e sur le fait que la premi�re note possible est un E2.


tab_nom_notes=['E '; 'F '; 'F#'; 'G '; 'G#'; 'A '; 'A#'; 'B '; 'C '; 'C#'; 'D '; 'D#'];
note=[tab_nom_notes(mod(indice_note_jouee,12)+1,:) num2str(octaveFondamentale)];


end

