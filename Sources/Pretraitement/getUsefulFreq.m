% getUsefulFreq.m
%   DESCRIPTION:
%       Ce script s'inscrit en pr�traitement de l'algorithme d'Onset Detection.
%       Non-utilis� actuellement.
%   BUT:
%       L'objectif est d'extraire de la stft, une bande de fr�quence
%       porteuse d'information concernant les onsets. On extrait donc les
%       fr�quences utiles.


sigma_y_sur_f=std(abs(y)')'; %Calcul de l'�cart-type sur f de la stft de l'audio

[nbFreq, level]=hist(sigma_y_sur_f, 200);  % Calcul de l'histogramme des fr�quences pr�sente
% Les fr�quences ayant une faible variance (dans mu_y_sur_f) doivent �tre
% �limin�es.

[nbFreqUseless, no_information_level_ind]=max(nbFreq); % Relev� dans l'histogramme du niveau dans mu_y_sur_f des fr�quences � �liminer (les plus nombreuses au m�me niveau)
no_information_level=level(no_information_level_ind);
% R�cup�ration des indices des fr�quences inutiles correspondant no_information_level
freqUseless_ind=find(sigma_y_sur_f<=no_information_level);
freqUseful_ind=find(sigma_y_sur_f>no_information_level);

% /!\ CECI DOIT ETRE MIS DANS UN ENDROIT PLUS LOGIQUE /!\
% y=zscore((abs(y))')'; % normalisation de y
break;

%% Visualisation
figure(1), clf, mesh(f(freqUseful_ind), t, y(freqUseful_ind,:)');
ylabel('Temps (s)'); xlabel('Fr�quence (Hz)'); title('Visualisation de la stft sur la bande utile');


figure(2), clf, mesh(f(freqUseless_ind), t, y(freqUseless_ind,:)');
ylabel('Temps (s)'); xlabel('Fr�quence (Hz)'); title('Visualisation de la stft sur la bande inutile');
