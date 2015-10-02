% getUsefulFreq.m
%   DESCRIPTION:
%       Ce script s'inscrit en pr�traitement de l'algorithme d'Onset Detection.
%       Non-utilis� actuellement.
%   BUT:
%       L'objectif est d'extraire de la stft, une bande de fr�quence
%       porteuse d'information concernant les onsets. On extrait donc les
%       fr�quences utiles.


sigmaYSurF=std(abs(y)')'; %Calcul de l'�cart-type sur f de la stft de l'audio

[nbFreq, level]=hist(sigmaYSurF, 200);  % Calcul de l'histogramme des fr�quences pr�sente
% Les fr�quences ayant une faible variance (dans muYSurF) doivent �tre
% �limin�es.

[nbFreqUseless, noInformationLevelInd]=max(nbFreq); % Relev� dans l'histogramme du niveau dans muYSurF des fr�quences � �liminer (les plus nombreuses au m�me niveau)
noInformationLevel=level(noInformationLevelInd);
% R�cup�ration des indices des fr�quences inutiles correspondant noInformationLevel
freqUselessInd=find(sigmaYSurF<=noInformationLevel);
freqUsefulInd=find(sigmaYSurF>noInformationLevel);

% /!\ CECI DOIT ETRE MIS DANS UN ENDROIT PLUS LOGIQUE /!\
% y=zscore((abs(y))')'; % normalisation de y
break;

%% Visualisation
figure(1), clf, mesh(f(freqUsefulInd), t, y(freqUsefulInd,:)');
ylabel('Temps (s)'); xlabel('Fr�quence (Hz)'); title('Visualisation de la stft sur la bande utile');


figure(2), clf, mesh(f(freqUselessInd), t, y(freqUselessInd,:)');
ylabel('Temps (s)'); xlabel('Fr�quence (Hz)'); title('Visualisation de la stft sur la bande inutile');
