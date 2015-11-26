function [ note ] = determinationNoteSegmentOctave_Harmonic_Product_Spectrum( segment , Fs)
%determinationNoteSegment.m

% HPS pour Harmonic Product Spectrum 

%   USAGE:
%       [ note ] = determinationNoteSegmentOctave( segment , Fs)
%
%	ATTRIBUTS:    
%       note:   Note d�tect� au au format string (Lettre anglosaxonne|# ou
%       espace|octave
%   
%       segment:     Extrait du signal audio d'origine 
%       Fs:      Fr�quence d'�chantillonnage de l'audio d'origine
%    
%	DESCRIPTION:   
%       On r�alise une fft sur le signal 'segment'. On compare cette fft
%       avec des mod�les de gaussienne centr�e sur les notes de E2 � E6.
%       On choisit alors celle qui correspond le mieux. Il y a une
%       subtilit� pour d�terminer l'octave.
%       Ne fonctionne actuellement que pour d�tecter une note � la fois (et
%       fonctionne mal...)
%	BUT:    
%       Renvoyer les notes jou�es dans le 'segment'

tabNomNotes=['R '; 'E '; 'F '; 'F#'; 'G '; 'G#'; 'A '; 'A#'; 'B '; 'C '; 'C#'; 'D '; 'D#'];

%% Calcul de la fft sur le segment
if(length(segment)<2^19)
    segFftWin=fft(segment.*blackman(length(segment)), 2^15);  %Permet d'assurer une pr�cision suffisante
    %   TODO: rendre ce paam�tre de fft d�pendant de la longueur du segment
    %   (mais toujours une puissance de 2).
else
    segFftWin=fft(segment.*blackman(length(segment)));
end
                                                  
                                                  
% Manipulation de la fft pour l'avoir sous la bonne forme
y=length(segFftWin);
axe_freq = (0:y/2-1)*Fs/y;
segFftWin=abs(segFftWin(1:(length(segFftWin)/2)));
 %figure, plot(axe_freq,segFftWin);

                                                  
hps1=downsample(segFftWin,1);
hps2=downsample(segFftWin,2);
hps3=downsample(segFftWin,3);
hps4=downsample(segFftWin,4);
hps5=downsample(segFftWin,5);
s = [];

for i=1:length(hps5)
      Product= hps1(i)*hps2(i)*hps3(i)*hps4(i)*hps5(i);
      s(i)=[Product];
end

[m,n]=findpeaks(s, 'SORTSTR', 'descend');
Maximum = n(1);


% Recherche des maximum de la fft 

indicemax_freq=Maximum*Fs/y;


% %% Recherche de la fr�quence la plus proche dans la table de notes
                                                  
tableNotes=generateTableNotes(false);   % G�n�re dans une table, les fr�quences des notes de E2 � E6 (plus d'autres infos)
tableNotes(:,:,3);
A = reshape(tableNotes(:,:,3),1,[]);
g=findClosest(A, indicemax_freq);
h=mod(g,12)+1;
if h==1
    h=h+12;
end

if (indicemax_freq<=63.5)
    octave=1;
elseif (indicemax_freq>63.5 && indicemax_freq<=127)
    octave=2;
elseif (indicemax_freq>127 && indicemax_freq<=244.5)
    octave=3;
elseif (indicemax_freq>244.5 && indicemax_freq<=508)
    octave=4;
elseif (indicemax_freq>508 && indicemax_freq<=1014)
    octave=5;
elseif (indicemax_freq>1014 && indicemax_freq<=2000)
    octave=6;
end
note=[tabNomNotes(h,:)  num2str(octave)];

end