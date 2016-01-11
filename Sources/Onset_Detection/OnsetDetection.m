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
% Normalisation 0 < oss < 100
pseudoComplexDomain = pseudoComplexDomain.*100/max(pseudoComplexDomain);
specFlux = specFlux.*100/max(specFlux);
% Combination des fonctions d'onset
FsOSS=(size(stftRes,2)/(length(x)/Fs));   %Rapport entre le nombre d'�chantillon du signal stft et ceux du signal "r�el" x.
ecart_ms = 50; w1 = 0.8; w2 = 1.2; %Param�tres de pond�ration de la combinaison
ecart_samples = round(ecart_ms*FsOSS/1000);
%specFlux est en avance sur pseudoComplexDomain de ecart_samples environ
oss = w1.*[zeros(ecart_samples,1); pseudoComplexDomain(1:end-ecart_samples)]+w2.*specFlux;



%% D�termination du seuil
rapportMoyenneLocale=40e-4; % regarde la moyenne locale sur plus d'�chantillons 
nbSampleMoyenneLocale = round(Fs*rapportMoyenneLocale);
nbPointMoyenneExtremite=round(Fs/h);

% Moyenne locale pour la partie gauche du signal
sommeSf_gauche=0;
for i=1:nbSampleMoyenneLocale
    for j=i:nbPointMoyenneExtremite+i
          sommeSf_gauche=sommeSf_gauche+oss(j);
    end
    moyenneLocaleGauche(i,1)=sommeSf_gauche/nbPointMoyenneExtremite;
    sommeSf_gauche=0;
end


% Moyenne locale pour le milieu du signal
moyenneLocaleCentre = filtfilt(ones(nbSampleMoyenneLocale,1)/nbSampleMoyenneLocale,1, oss);

% Moyenne locale pour la partie droite du signal
sommeSf_droit=0;
for u=length(oss)-nbSampleMoyenneLocale:length(oss)
    for l = u-nbPointMoyenneExtremite-1:u

          sommeSf_droit=sommeSf_droit+oss(l);
    end
    moyenneLocaleDroite(u,1)=sommeSf_droit/nbPointMoyenneExtremite;
    sommeSf_droit=0;
end


% Cr�ation du vecteur final repr�sentant la moyenne locale         
moyenneFinale=zeros(length(oss),1);
moyenneFinale(1:nbSampleMoyenneLocale-1,1)= moyenneLocaleGauche(1:nbSampleMoyenneLocale-1,1);
moyenneFinale(nbSampleMoyenneLocale:length(oss)-nbSampleMoyenneLocale,1)=moyenneLocaleCentre(nbSampleMoyenneLocale:length(oss)-nbSampleMoyenneLocale,1);
moyenneFinale(length(oss)-nbSampleMoyenneLocale:length(oss),1)=moyenneLocaleDroite(length(oss)-nbSampleMoyenneLocale:length(oss),1);

% Ajustement des courbes (compensation des discontinuit�s)
% ecart1=moyenneFinale(nbSampleMoyenneLocale-1)-moyenneFinale(nbSampleMoyenneLocale);
% moyenneFinale(1:nbSampleMoyenneLocale,1)=moyenneLocaleGauche(1:nbSampleMoyenneLocale,1)+ecart1;
coef=moyenneFinale(nbSampleMoyenneLocale)/moyenneFinale(nbSampleMoyenneLocale-1);
moyenneFinale(1:nbSampleMoyenneLocale,1)=moyenneLocaleGauche(1:nbSampleMoyenneLocale,1)*coef;

coef2=moyenneFinale(length(oss)-(nbSampleMoyenneLocale+1))/moyenneFinale(length(oss)-nbSampleMoyenneLocale);
moyenneFinale(length(oss)-nbSampleMoyenneLocale:length(oss),1)=moyenneLocaleDroite(length(oss)-nbSampleMoyenneLocale:length(oss),1)*coef2;

% ecart2=moyenneFinale(length(oss)-nbSampleMoyenneLocale)-moyenneFinale(length(oss)-(nbSampleMoyenneLocale+1));
% moyenneFinale(length(oss)-nbSampleMoyenneLocale:length(oss),1)=moyenneLocaleDroite(length(oss)-nbSampleMoyenneLocale:length(oss),1)-ecart2;
seuil=moyenneFinale*1;

% Moyenne globale pour detection des silences
moyenneGlobale = mean(oss);

% Seuil minimal � atteindre pour d�tecter un pic.
% un seuil global fixe a 50% de la moyenne donne de bons resultats
PourcentSeuilGlobal = 65;
seuilGlobal(1:size(oss), 1) = moyenneGlobale*PourcentSeuilGlobal/100;

%% Param�tres d�tection de pics
ecartMinimal= round(60/240*FsOSS);   %ecart correspondant � 240 bpm

%% D�tection des pics
[amplitudeOnsets, sampleIndexOnsets]=ovldFindpeaks(oss, 'MINPEAKHEIGHT', seuil, 'MINPEAKDISTANCE', floor(ecartMinimal/2), 'THRESHOLD',0);

sampleIndexOnsets(find(oss(sampleIndexOnsets)<moyenneGlobale*PourcentSeuilGlobal/100))=[];

% %% M�thode annexe, globalement la m�me chose ...
% difference=[1; -1];
% deriveeOSS = sign(filter(difference, 1, oss));
% sampleIndexOnsets=find(integrateur(deriveeOSS)==1)'-ecart_samples;
% sampleIndexOnsets(sampleIndexOnsets<0)=[];
% sampleIndexOnsets(oss(sampleIndexOnsets)<seuil(sampleIndexOnsets)*0.85)=[];
% sampleIndexOnsets(oss(sampleIndexOnsets)<mean(oss)*0.5)=[];

%% OFFSET Detection

% Coefficients d'un filtre de d�riv�e.
a=1; b=[1 -1];
 
% derivee du seuil
d_seuil = filter(b, a, seuil);
d_seuil(1) = 0;

[pks, sampleIndexOffsets]=findpeaks(-d_seuil, 'MINPEAKHEIGHT', mean(-d_seuil)+std(d_seuil));

% Suppression des silences faussement d�tect�

% dernier silence
sampleIndexOffsets(sampleIndexOffsets<sampleIndexOnsets(1)) = [];
last_silence = find(sampleIndexOffsets>sampleIndexOnsets(end), 1, 'first');
if ~isempty(last_silence)
    if last_silence ~= length(sampleIndexOffsets)
        sampleIndexOffsets(last_silence+1:end)=[];
    end
end
% offsets sur un onset
sampleIndexOffsets(find(ismember(sampleIndexOffsets,sampleIndexOnsets)))=[];
sampleIndexOffsets(find(ismember(sampleIndexOffsets,sampleIndexOnsets-1)))=[];
sampleIndexOffsets(find(ismember(sampleIndexOffsets,sampleIndexOnsets+1)))=[];

% non d�rivabilit� de la fonction seuil

offsetToRm = find(sampleIndexOffsets==(nbSampleMoyenneLocale-1));
sampleIndexOffsets(offsetToRm)=[];
offsetToRm = find(sampleIndexOffsets==(length(oss)-nbSampleMoyenneLocale));
sampleIndexOffsets(offsetToRm)=[];

% double silences
for l = length(sampleIndexOffsets):-1:2
    lastOnset = find(sampleIndexOnsets<sampleIndexOffsets(l), 1, 'last');
    if(sampleIndexOnsets(lastOnset)<sampleIndexOffsets(l-1))
        sampleIndexOffsets(l)=[];
    end
    clear lastOnset;
end

silences = zeros(size(oss));
silences(sampleIndexOffsets) = 1;

indOn = [sampleIndexOnsets];
indOn(:, 2) = 0;
indOff = [sampleIndexOffsets];
indOff(:, 2) = 1;

indOnOff = [indOn ; indOff];
indOnOff = sortrows(indOnOff,1);

%% Postprocessing
sampleIndexOnsets=sampleIndexOnsets-ecart_samples;% Correction de l'�cart temporel apport� par la combinaision des deux fonctions d'onsets.
visualOnsets=zeros(size(oss));
visualOnsets(round(sampleIndexOnsets))=1;
%% Fin de l'algorithme

% Visualisation des r�sultats
% if(length(seuil)==1)
%     figure(1), plot(t, [oss max(oss)*visualOnsets seuil seuilGlobal max(oss)*silences])
% else
%      figure(1), plot(t, [oss max(oss)*visualOnsets seuil max(oss)*silences])  
% end

clear N h degreLissage indexPremierPic indexDernierPic amplitudeOnsets rapportMoyenneLocale ecartMinimal sensibilite;
