%analyseOpenString.m

addpath('Data/STAGG/open string/')
addpath('Data/STAGG/double open-string/')
addpath('Data/STAGG/F+5/')
addpath('Data/STAGG/Bends - 7th/')
[x,Fs,Nbits] = wavread('Data/STAGG/Bends - 7th/B2.wav');
x=mean(x, 2);

% Filtrage sur la bande de fr�quence qui nous int�resse.
tableNotes=generateTableNotes(false);
[B, A]=butter(5,  [min(min(tableNotes(:,:,2)))/Fs*2 max(max(max(tableNotes)))/Fs*2]);
x=filter(B, A, x);
x=xcorr(x);
t = (1/Fs:1/Fs:length(x)/Fs)';

%% Calcul de la fft sur le x
if(length(x)<2^15)
    seg_fft_win=fft(x.*blackman(length(x)), 2^15);  %Permet d'assurer une pr�cision suffisante
else
    seg_fft_win=fft(x.*blackman(length(x)));
end
seg_fft_win = fftshift(abs(seg_fft_win));
seg_fft_win=seg_fft_win(round((length(seg_fft_win)/2)):end);
seg_fft_win=abs(seg_fft_win);
seg_fft_win_phase=fftshift(angle(seg_fft_win));

f=((Fs/(length(seg_fft_win))/2:(Fs/(length(seg_fft_win)))/2:Fs/2));

%% Projection de la fft sur le filtre g�n�r�. Mets en �vidence les pics �
% des fr�quences de note normalis�es.
bornes_octaves=sort([tableNotes(1,:,2) tableNotes(1,end,4)])';
ind_bornes_octaves=findClosest(f, bornes_octaves);

%% g�n�ration d'un filtre pour la pond�ration de chaque note
filtre=generateGaussian(length(abs(seg_fft_win)), Fs, tableNotes);
projection_win= filtre.*repmat(seg_fft_win, 1, 12);

%Visualisation
%semilogx(f, [seg_fft_win/max(seg_fft_win)*2 filtre]);

for i=1:length(ind_bornes_octaves)-1
    %Puissance �gale somme des carr�s.
    sum_projection(:,i)=sum(projection_win(ind_bornes_octaves(i):ind_bornes_octaves(i+1),:).^2,1)';
end

tab_nom_notes=['E '; 'F '; 'F#'; 'G '; 'G#'; 'A '; 'A#'; 'B '; 'C '; 'C#'; 'D '; 'D#'];

%S�lection du r�sultat maximum de cette projection.

[valMax indice_note_jouee]=max(mean(sum_projection,2)); %N'est valable que pour 1 note jou�e � la fois
projection_deroulee=sum_projection(:);

% L'instruction qui suit est cmopl�tement fausse
ind_compoTonale=find(projection_deroulee>(mean(projection_deroulee)));
octaveFondamentale=floor((ind_compoTonale(1)+3)/12)+2;    %Cette mise � l'�chelle est bas�e sur le fait que la premi�re note possible est un E2.

note=[tab_nom_notes(indice_note_jouee,:) num2str(octaveFondamentale)]

%% Visualisation
% 
 bar3(sum_projection');
 set(gca, 'XTick',1:12, 'XTickLabel',{'E ' 'F ' 'F#' 'G ' 'G#' 'A ' 'A#' 'B ' 'C ' 'C#' 'D ' 'D#'})
proportion=sum_projection./max(max(sum_projection))*100

%% R�sultats:
