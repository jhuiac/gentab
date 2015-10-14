%tempoDetection.m
%
%   Ce script tente de d�terminer le tempo du morceau � partir de la sortie
%   de l'algorithme d'OD.
%   Il fait appel � l'autocorr�lation comme d�crit dans
%   Ellis07-beattracking.pdf



%% Filtrage passe-haut du signal 
% Pour avoir une moyenne nulle
f = 0.4/FsSF; % Fr�quence de coupure � 4Hz
[b,a]=butter(2, 2*pi*f, 'high');
sfFiltered = filter(b, a, sf);

%% Calcul de l'auto corr�lation
autoCorr = xcorr(sfFiltered, sfFiltered, 'unbiased');
autoCorr = autoCorr(floor(length(autoCorr)/2)+1:end);
tAutoCorr = (1/FsSF:1/FsSF:length(autoCorr)/FsSF)';

%% Calcul de la fen�tre comme donn� dans la documentation
tau0 = 0.5; % en seconde (correspond � 1/120bpm)
sigma0 = 1.4; % en octaves
W=exp(-0.5*(log2(tAutoCorr/tau0)/sigma0).^2);

%% Fonction de froce du tempo(tempo strength)
TPS = W.*abs(autoCorr);
%% Visualisation
%plot(tAutoCorr, TPS, 'b', tAutoCorr, W*max(TPS), 'r');

%% Calcul du tempo
[val, ind]=max(TPS);
tempo=60/tAutoCorr(ind);

while tempo>160
    tempo=tempo/2;
end
tempo = 2*round(tempo/2);    % arrondi par 2