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
N=2^11; h=190;   %fonctionne bien pour h=441

% Degr� de lissage
degreLissage=round(Fs/h/10);

%% D�but de l'algorithme
% Stft (Short-Time Fourier Transform)
[stftRes, t, f]=stft(x, Fs, 2^11, h, N); %Ces param�tres semblent ceux donnant les meilleurs r�sultats � ce jour

%figure(1), clf, mesh(f(1:findClosest(f, 1e4)),t,20*log10(abs(stftRes((1:findClosest(f, 1e4)), :)))'); ylabel('Temps (s)'); xlabel('Fr�quence (Hz)');

%% Fonctions d'onset
% Pseudo-complex domain
pseudoComplexDomain=getOnsets(stftRes,70,1500,Fs,N);

% Spectral flux
specFlux = spectralflux(stftRes);


% Filtrage pour �liminer les parasites
[B, A]=butter(2, [0.2 0.9999], 'stop'); %Un filtre coupe-bande qui ne garde que les 20%plus basses fr�quences et les 0.1% plus hautes.
pseudoComplexDomain=filter(B,A,pseudoComplexDomain);
specFlux=filter(B,A,specFlux);
pseudoComplexDomain=filtfilt(ones(degreLissage,1)/degreLissage, 1, pseudoComplexDomain);  % Lissage du spectral flux (pour �viter les faux pics de faible amplitude)
specFlux=filtfilt(ones(degreLissage,1)/degreLissage, 1, specFlux);  % Lissage du spectral flux (pour �viter les faux pics de faible amplitude)
% Normalisation 0 < sf < 100
pseudoComplexDomain = pseudoComplexDomain.*100/max(pseudoComplexDomain);
specFlux = specFlux.*100/max(specFlux);

% Combination des fonctions d'onset
FsSF=(size(stftRes,2)/(length(x)/Fs));   %Rapport entre le nombre d'�chantillon du signal sftft et ceux du signal "r�el" x.
ecart_ms = 50; w1 = 0.8; w2 = 1.2; %Param�tres de pond�ration de la combinaison
ecart_samples = round(ecart_ms*FsSF/1000);
%specFlux est en avance sur pseudoComplexDomain de ecart_samples environ
sf = w1.*[zeros(ecart_samples,1); pseudoComplexDomain(1:end-ecart_samples)]+w2.*specFlux;

%% D�termination du seuil
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
seuil=moyenneFinale;

%% Param�tres d�tection de pics
ecartMinimal= round(60/240*FsSF);   %ecart correspondant � 240 bpm

%% D�tection des pics
[amplitudeOnsets, sampleIndexOnsets]=ovldFindpeaks(sf, 'MINPEAKHEIGHT', seuil, 'MINPEAKDISTANCE', floor(ecartMinimal/2), 'THRESHOLD',0);

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

%% Fin de l'algorithme
% Visualisation des r�sultats
if(length(seuil)==1)
    plot(t, [sf max(sf)*visualOnsets ones(size(sf))*seuil])
else
    plot(t, [sf max(sf)*visualOnsets seuil])  
end

clear N h degreLissage indexPremierPic indexDernierPic amplitudeOnsets rapportMoyenneLocale ecartMinimal sensibilite;
