% OnsetDetection.m
%   DESCRIPTION: Script de haut niveau (wrapper), rassemblant les diff�rentes fonctions ordonn�es
%   pour la d�tection des onsets.
%       La d�tection des onsets correspond � la d�tection du d�but d'une
%       note jou�e. La fin d'une note jou�e est un offset. On ne cherche
%       pas � identifier ces derniers car souvent une note est
%       imm�diatement suivie d'une autre (donc un onset). Cependant, quand
%       le son qui suit une note est silence, il faut alors d�terminer
%       l'offset.
%   BUT: indiquer dans un vecteur les �chantillons pour lesquelles une note
%   commence (ou fini). Un silence doit �tre consid�r� comme une note. Il
%   ne peut y avoir qu'un onset (offset) entre deux notes.

%% D�finition des param�tres de pr�traitement

%Param�tres de la stft
Nfft=2^12; h=190;   %fonctionne bien pour h=441

% Degr� de lissage
degreLissage=round(Fs/h/10); %Fs/h correspond � la sensibilit� temporelle de la stft
%% N�c�ssite une �tape de pr�traitement
% getUsefulFreq

%% D�but de l'algorithme
% Stft (Short-Time Fourier Transform)
[stftRes, t, f]=stft(x, Fs, Nfft, h, Nfft); %Ces param�tres semblent ceux donnant les meilleurs r�sultats � ce jour
%figure(1), clf, mesh(f(1:findClosest(f, 1e4)),t,20*log10(abs(stftRes((1:findClosest(f, 1e4)), :)))'); ylabel('Temps (s)'); xlabel('Fr�quence (Hz)');


%%
%   complex spectral difference method
sf=getOnsets(stftRes,20,20000, Fs, Nfft);
sf=filtfilt(ones(degreLissage,1)/degreLissage, 1, sf);  % Lissage du spectral flux (pour �viter les faux pics de faible amplitude)

%% Param�tre d�tection de pics
FsSF=(length(sf)/(length(x)/Fs));   %Rapport entre le nombre d'�chantillon du signal sftft (et sf) et ceux du signal "r�el" x.
ecartMinimal= round(60/240*FsSF);   %ecart correspondant � 240 bpm
sensibilite=0.00*std(sf);    %Sensibilit� de la d�tection du pic. Relative � l'amplitude de sf. Cf help findpeaks

%% D�termination du seuil - 2 options
% Option 1: moyenne locale
rapportMoyenneLocale=40e-4; % regarde la moyenne locale sur plus d'�chantillons
nbSampleMoyenneLocale = round(Fs*rapportMoyenneLocale);
moyenneLocale = filtfilt(ones(nbSampleMoyenneLocale,1)/nbSampleMoyenneLocale,1, sf);
 
%Le seuil semble �tre un peu trop �lev� mais bien suivre la courbe.
seuil=moyenneLocale;   %R�duction par 10%
%seuil=moyenneLocale;
%sf=sf-moyenneLocale;

% Option 2: moyenne g�n�rale
%seuil=mean(sf);                     % Seuil minimal � atteindre pour d�tecter un pic.
%% D�tection des peaks
% TODO: comment utiliser findpeaks avec un seuil variable
[amplitudeOnsets, sampleIndexOnsets]=ovldFindpeaks(sf, 'MINPEAKHEIGHT', seuil, 'MINPEAKDISTANCE', floor(ecartMinimal/2), 'THRESHOLD',sensibilite);

% 2 autres fonction de d�tection de pics fonctionnant moins bien
% maxtab=peakdet(sf, seuil, (length(sf)/(length(x)/Fs)));
% [pks, loc, width, resid]=peakdet2(sf, length(sf), 3*ecartmin, 100*ecartmin, seuil);

% suppression des premiers pics jusqu'au premier pic � d�passer la moiti�e de la moyenne
% globale (� terme moyenne locale long terme)
indexPremierPic=1;
while(amplitudeOnsets(indexPremierPic)<mean(sf)/2)
    indexPremierPic=indexPremierPic+1;
end
% suppression des derniers pics jusqu'au premier pic � d�passer la moiti�e de la moyenne
% globale (� terme moyenne locale long terme)
indexDernierPic=length(amplitudeOnsets);
while(amplitudeOnsets(indexDernierPic)<mean(sf)/2)
    indexDernierPic=indexDernierPic-1;
end

sampleIndexOnsets=sampleIndexOnsets(indexPremierPic:indexDernierPic);
visualOnsets=zeros(size(sf));
visualOnsets(round(sampleIndexOnsets))=1;

%% D�tections des silences (offsets)
% TODO: proposer une solution valable pour cette partie.
%peaks=peaks+detectionSilences(sf, 1);

%% Fin de l'algorithme
% Visualisation des r�sultats
if(length(seuil)==1)
    figure(1),clf, plot(t, [sf max(sf)*visualOnsets ones(size(sf))*seuil])
else
    figure(2),plot(t, [sf max(sf)*visualOnsets seuil])  
end

clear N h degreLissage indexPremierPic indexDernierPic amplitudeOnsets moyenneLocale rapportMoyenneLocale nbSampleMoyenneLocale ecartMinimal sensibilite;
