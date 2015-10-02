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
    segmentFFTWindowed=fft(x.*blackman(length(x)), 2^15);  %Permet d'assurer une pr�cision suffisante
else
    segmentFFTWindowed=fft(x.*blackman(length(x)));
end
segmentFFTWindowed = fftshift(abs(segmentFFTWindowed));
segmentFFTWindowed=segmentFFTWindowed(round((length(segmentFFTWindowed)/2)):end);
segmentFFTWindowed=abs(segmentFFTWindowed);
segmentFFTWindowedPhase=fftshift(angle(segmentFFTWindowed));

f=((Fs/(length(segmentFFTWindowed))/2:(Fs/(length(segmentFFTWindowed)))/2:Fs/2));

%% Projection de la fft sur le filtre g�n�r�. Mets en �vidence les pics �
% des fr�quences de note normalis�es.
bornesOctaves=sort([tableNotes(1,:,2) tableNotes(1,end,4)])';
indicesBornesOctaves=findClosest(f, bornesOctaves);

%% g�n�ration d'un filtre pour la pond�ration de chaque note
filtre=generateGaussian(length(abs(segmentFFTWindowed)), Fs, tableNotes);
projectionWindowed= filtre.*repmat(segmentFFTWindowed, 1, 12);

%Visualisation
%semilogx(f, [segmentFFTWindowed/max(segmentFFTWindowed)*2 filtre]);

for i=1:length(indicesBornesOctaves)-1
    %Puissance �gale somme des carr�s.
    sumProjection(:,i)=sum(projectionWindowed(indicesBornesOctaves(i):indicesBornesOctaves(i+1),:).^2,1)';
end

tabNomNotes=['E '; 'F '; 'F#'; 'G '; 'G#'; 'A '; 'A#'; 'B '; 'C '; 'C#'; 'D '; 'D#'];

%S�lection du r�sultat maximum de cette projection.

[valMax indiceNoteJouee]=max(mean(sumProjection,2)); %N'est valable que pour 1 note jou�e � la fois
projectionDeroulee=sumProjection(:);

% L'instruction qui suit est cmopl�tement fausse
indCompoTonale=find(projectionDeroulee>(mean(projectionDeroulee)));
octaveFondamentale=floor((indCompoTonale(1)+3)/12)+2;    %Cette mise � l'�chelle est bas�e sur le fait que la premi�re note possible est un E2.

note=[tabNomNotes(indiceNoteJouee,:) num2str(octaveFondamentale)]

%% Visualisation
% 
 bar3(sumProjection');
 set(gca, 'XTick',1:12, 'XTickLabel',{'E ' 'F ' 'F#' 'G ' 'G#' 'A ' 'A#' 'B ' 'C ' 'C#' 'D ' 'D#'})
proportion=sumProjection./max(max(sumProjection))*100

%% R�sultats:
