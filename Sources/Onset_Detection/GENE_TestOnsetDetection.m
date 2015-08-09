% GENE_TestOnsetDetection.m
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
degre_lissage=10;
%Param�tres de la stft
N=2^11; h=441;   %fonctionne bien pour h=441

%% N�c�ssite une �tape de pr�traitement
% getUsefulFreq

%% D�but de l'algorithme
% Stft (Short-Time Fourier Transform)
[stft_res, t, f]=stft(x, Fs, 2^11, h, N); %Ces param�tres semblent ceux donnant les meilleurs r�sultats � ce jour
%figure(1), clf, mesh(f(1:findClosest(f, 1e4)),t,20*log10(abs(stft_res((1:findClosest(f, 1e4)), :)))'); ylabel('Temps (s)'); xlabel('Fr�quence (Hz)');

%%% 
% Spectral flux
sf=spectralflux(stft_res)';

%%
%   Phase Deviation (TODO)

sf=filtfilt(ones(degre_lissage,1)/degre_lissage, 1, sf);  % Lissage du spectral flux (pour �viter les faux pics de faible amplitude)
%% Param�tre d�tection de pics
FsSF=(length(sf)/(length(x)/Fs));   %Rapport entre le nombre d'�chantillon du signal sftft (et sf) et ceux du signal "r�el" x.
ecart_minimal= round(60/240*FsSF);   %ecart correspondant � 240 bpm
sensibilite=0.00*std(sf);    %Sensibilit� de la d�tection du pic. Relative � l'amplitude de sf. Cf help findpeaks

%% D�termination du seuil - 2 options
% Option 1: moyenne locale
rapport_moyenne_locale=1e-3;
nb_sample_moyenne_locale = round(Fs*rapport_moyenne_locale);
moyenne_locale = filtfilt(ones(nb_sample_moyenne_locale,1)/nb_sample_moyenne_locale,1, sf);
 
%Le seuil semble �tre un peu trop �lev� mais bien suivre la courbe.
seuil=moyenne_locale;   %R�duction par 10%
%seuil=moyenne_locale;
%sf=sf-moyenne_locale;

% Option 2: moyenne g�n�rale
%seuil=mean(sf);                     % Seuil minimal � atteindre pour d�tecter un pic.
%% D�tection des peaks
% TODO: comment utiliser findpeaks avec un seuil variable
[amplitude_onsets, sample_index_onsets]=ovld_findpeaks(sf, 'MINPEAKHEIGHT', seuil, 'MINPEAKDISTANCE', floor(ecart_minimal/2), 'THRESHOLD',sensibilite);

% 2 autres fonction de d�tection de pics fonctionnant moins bien
% maxtab=peakdet(sf, seuil, (length(sf)/(length(x)/Fs)));
% [pks, loc, width, resid]=peakdet2(sf, length(sf), 3*ecartmin, 100*ecartmin, seuil);

% suppression des premiers pics jusqu'au premier pic � d�passer la moyenne
% globale (� terme moyenne locale long terme)
i=1;
while(amplitude_onsets(i)<mean(sf))
    i=i+1;
end
sample_index_onsets=sample_index_onsets(i:end);
visual_onsets=zeros(size(sf));
visual_onsets(round(sample_index_onsets))=1;

%% D�tections des silences (offsets)
% TODO: proposer une solution valable pour cette partie.
%peaks=peaks+detection_silences(sf, 1);

%% Fin de l'algorithme
% Visualisation des r�sultats
if(length(seuil)==1)
    figure(2),plot(t, [sf max(sf)*visual_onsets ones(size(sf))*seuil])
else
    figure(2),plot(t, [sf max(sf)*visual_onsets seuil])  
end
clear N h degre_lissage i amplitude_onsets moyenne_locale rapport_moyenne_locale nb_sample_moyenne_locale ecart_minimal sensibilite;
