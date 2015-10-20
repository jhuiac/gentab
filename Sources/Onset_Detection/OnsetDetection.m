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
% Degr� de lissage
N=2^11; h=190;   %fonctionne bien pour h=441

degreLissage=round(Fs/h/10);
%Param�tres de la stft

%% N�c�ssite une �tape de pr�traitement
% getUsefulFreq

%% D�but de l'algorithme
% Stft (Short-Time Fourier Transform)
[stftRes, t, f]=stft(x, Fs, 2^11, h, N); %Ces param�tres semblent ceux donnant les meilleurs r�sultats � ce jour
%figure(1), clf, mesh(f(1:findClosest(f, 1e4)),t,20*log10(abs(stftRes((1:findClosest(f, 1e4)), :)))'); ylabel('Temps (s)'); xlabel('Fr�quence (Hz)');


%% complex spectral difference method
%  Association de la m�thode du flux spectrale et de la d�viation de phase
%  pour une meilleure d�tection des Onsets
sf=getOnsets(stftRes,20,20000);

sf=filtfilt(ones(degreLissage,1)/degreLissage, 1, sf);  % Lissage du spectral flux (pour �viter les faux pics de faible amplitude)
%% Param�tre d�tection de pics
FsSF=(length(sf)/(length(x)/Fs));   %Rapport entre le nombre d'�chantillon du signal sftft (et sf) et ceux du signal "r�el" x.
ecartMinimal= round(60/240*FsSF);   %ecart correspondant � 240 bpm
sensibilite=0.00*std(sf);    %Sensibilit� de la d�tection du pic. Relative � l'amplitude de sf. Cf help findpeaks

%% D�termination du seuil - 2 options
% Option 1: moyenne locale
rapportMoyenneLocale=40e-4; % regarde la moyenne locale sur plus d'�chantillons 
nbSampleMoyenneLocale = round(Fs*rapportMoyenneLocale);
nbPointMoyenneExtremite=round(Fs/h);

% Moyenne locale pour la partie gauche du signal
sommeSf_gauche=0;
for i=1:nbSampleMoyenneLocale
    for j=i:nbPointMoyenneExtremite+i
          sommeSf_gauche=sommeSf_gauche+sf(j);
    end
    moyenneLocaleGauche(i,1)=sommeSf_gauche/nbPointMoyenneExtremite;
    sommeSf_gauche=0;
end


% Moyenne locale pour le milieu du signal
moyenneLocaleCentre = filtfilt(ones(nbSampleMoyenneLocale,1)/nbSampleMoyenneLocale,1, sf);

% Moyenne locale pour la partie droite du signal
sommeSf_droit=0;
for u=length(sf)-nbSampleMoyenneLocale:length(sf)
    for l=u-nbPointMoyenneExtremite-1:u

          sommeSf_droit=sommeSf_droit+sf(l);
    end
    moyenneLocaleDroite(u,1)=sommeSf_droit/nbPointMoyenneExtremite;
    sommeSf_droit=0;
end


% Cr�ation du vecteur final repr�sentant la moyenne locale         
moyenneFinale=zeros(length(sf),1);
moyenneFinale(1:nbSampleMoyenneLocale-1,1)=moyenneLocaleGauche(1:nbSampleMoyenneLocale-1,1);
moyenneFinale(nbSampleMoyenneLocale:length(sf)-nbSampleMoyenneLocale,1)=moyenneLocaleCentre(nbSampleMoyenneLocale:length(sf)-nbSampleMoyenneLocale,1);
moyenneFinale(length(sf)-nbSampleMoyenneLocale:length(sf),1)=moyenneLocaleDroite(length(sf)-nbSampleMoyenneLocale:length(sf),1);

% Ajustement des courbes (compensation des discontinuit�s)
% ecart1=moyenneFinale(nbSampleMoyenneLocale-1)-moyenneFinale(nbSampleMoyenneLocale);
% moyenneFinale(1:nbSampleMoyenneLocale,1)=moyenneLocaleGauche(1:nbSampleMoyenneLocale,1)+ecart1;
coef=moyenneFinale(nbSampleMoyenneLocale)/moyenneFinale(nbSampleMoyenneLocale-1);
moyenneFinale(1:nbSampleMoyenneLocale,1)=moyenneLocaleGauche(1:nbSampleMoyenneLocale,1)*coef;

coef2=moyenneFinale(length(sf)-(nbSampleMoyenneLocale+1))/moyenneFinale(length(sf)-nbSampleMoyenneLocale);
moyenneFinale(length(sf)-nbSampleMoyenneLocale:length(sf),1)=moyenneLocaleDroite(length(sf)-nbSampleMoyenneLocale:length(sf),1)*coef2;

% ecart2=moyenneFinale(length(sf)-nbSampleMoyenneLocale)-moyenneFinale(length(sf)-(nbSampleMoyenneLocale+1));
% moyenneFinale(length(sf)-nbSampleMoyenneLocale:length(sf),1)=moyenneLocaleDroite(length(sf)-nbSampleMoyenneLocale:length(sf),1)-ecart2;


% Le seuil semble �tre un peu trop �lev� mais bien suivre la courbe.
seuil=moyenneFinale;   %R�duction par 10%
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
    figure,plot(t, [sf max(sf)*visualOnsets ones(size(sf))*seuil])
else
    figure,plot(t, [sf max(sf)*visualOnsets seuil])  
end

clear N h degreLissage indexPremierPic indexDernierPic amplitudeOnsets rapportMoyenneLocale ecartMinimal sensibilite;
