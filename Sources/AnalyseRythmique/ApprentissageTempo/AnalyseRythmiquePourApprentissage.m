function [varargout] = analyseRythmiquePourApprentissage(oss, bornes, FsOSS, Fs, display)
%   analyseRythmique.m
%
%   USAGE: 
%       [durees, tempo] = analyseRythmique(oss, bornes, FsOSS, Fs, 1);
%   ATTRIBUTS:
%       durees: durees de chaque note dans l'ordre. Format: nombre de
%       double-croches (croche = 2, noire = 4)
%       tempo: tempo estim� du morceau
%
%       oss: Onset Strength Signal - sortie de la fonction de d�tection d'onset detection
%       bornes: �chantillons dans la base du temps d'origine pour lesquels,
%       un onset est d�tect�
%       FsOSS: Fr�quence d'�chantillonnage apr�s la fonction d'osnet
%       detection
%       Fs : Fr�quence d'�chantillonnage du morceau
%
%       display: si vrai, affiche deux graphe repr�sentant la r�partition
%       des dur�es de notes.
%
%   BUT:
%       Cette fonction tente de d�terminer la dur�es musicale de chaque
%       note. D'autre part elle d�termine le tempo via la fonction
%       determinationTempoV3 en passant par l'autocorr�lation de oss.
%       Pour la d�termination des dur�es de notes, on d�termine des
%       intervalles de dur�es (en s) qui correspondent � chaque dur�e
%       musicale potentielle. La largeur des ces intervalles d�pend de la
%       probabilit� pour une note d'appartenir � une certaine classe.      

    if nargin <4
        display = false;
    end

    ecart=diff(bornes)/Fs; % �cart entre deux bornes en secondes
    generatePeigneGaussienne;

    %% D�termination de la densit� de probabilit� des tempos
    determinationTempoV3; % Les r�sultats sont globalement bon mais il peut y avoir un �cart d'un facteur 2.
    % S�l�ection des candidats
    [~, temposCandidats]=findpeaks(C, 'SORTSTR', 'descend');
    
    for tau=1:length(temposCandidats)
    %% D�termination des dur�es de notes
        ecartRef=60/temposCandidats(tau); %coefficient de normalisation des �carts
        indiceEcartsPourPeigne = findClosest(abscisse,ecart/ecartRef*4);
        probas=peigneGaussienne(indiceEcartsPourPeigne,:);
        [probasMax(:,tau), durees] = max(probas');
    end
    % Choix du meilleur tempo candidat
    mu_Tau=mean(probasMax);
    [~, tauMeilleur]=max(mu_Tau);
    tempo=temposCandidats(tauMeilleur);
    
    %% Calcul des param�tres pour la SVM
    ecartAutoriseBPM = 4;
    features = [sumInRange(C,1,tempo-ecartAutoriseBPM-1);
                sumInRange(C,tempo+ecartAutoriseBPM+1,length(C))];
    features=[features;sumInRange(C,tempo/2-ecartAutoriseBPM,tempo/2+ecartAutoriseBPM)];
    features=[features;sumInRange(C, tempo-ecartAutoriseBPM, tempo+ecartAutoriseBPM);
        sumInRange(C,2*tempo-ecartAutoriseBPM,2*tempo+ecartAutoriseBPM)]; %Pb: on srt de C
    features=[features;
                length(find(C>0));
                tempo];
        
    mins = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,      minBPM];
    maxs = [ 1.0, 1.0, 1.0, 1.0, 1.0, maxBPM,   maxBPM];

    features_normalized = zeros(size(features));
    for i = 1:length(features)
        if mins(i) ~= maxs(i)
            features_normalized(i) = ((features(i) - mins(i)) / (maxs(i) - mins(i)));
        end
    end
    
    %% Fin de la fonction
    if nargout==2
        varargout{1}=tempo;
        varargout{2}=features_normalized;
    end
end