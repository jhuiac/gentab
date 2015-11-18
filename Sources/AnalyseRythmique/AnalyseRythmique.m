function [varargout] = analyseRythmique(oss, bornes, FsOSS, Fs, display, tempo)
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
%       tempo: si le tempo est donn� en entr�e, il n'est pas estim� dans
%       l'algorithme.
%
%   BUT:
%       Cette fonction tente de d�terminer la dur�es musicale de chaque
%       note. D'autre part elle d�termine le tempo via la fonction
%       determinationTempoV2 en passant par l'autocorr�lation de oss.
%       Pour la d�termination des dur�es de notes, on d�termine des
%       intervalles de dur�es (en s) qui correspondent � chaque dur�e
%       musicale potentielle. La largeur des ces intervalles d�pend de la
%       probabilit� pour une note d'appartenir � une certaine classe.      

    if nargin <4
        display = false;
    end
        %%
    ecart=diff(bornes)/Fs; % �cart entre deux bornes en secondes

%     probabilitesInitiales = [0.15;0.3;0.05;0.2;0.05;0.1;0.02;0.05;0;0;0;0.05;0;0;0;0.03];
%     % probabilitesInitialesV2 est issu de la publication
%     % ViitKE03-melodies.pdf
%     probabilitesInitialesV2 = [0.02;0.107;0.009;0.079;0.0005;0.01;0.0005;0.0201;0;0;0;0.0005;0;0;0;0.006];
%     probabilitesInitialesV2 = probabilitesInitialesV2*1/sum(probabilitesInitialesV2);
%     
%     probabilitesInitiales = probabilitesInitialesV2;
%     facteursReferences = (0.25:0.25:4)'; % facteur multiplicatif par rapport � la noire=1 (ronde=4, croche = 0.5)
% 
%     %% Calcul des intervalles
%     edgeHistogramme = [0];
%     decalage = 0;
%     for k=1:length(facteursReferences)-1
%         if(probabilitesInitiales(k+1) == 0)
%             decalage=decalage+1;
%         else
%             edgeHistogramme(k+1)= getBarycentre(facteursReferences(k-decalage), facteursReferences(k+1), probabilitesInitiales(k+1), probabilitesInitiales(k-decalage)); %la probabilit� d'un point est donn�e � l'autre point car il y a une notion dinverse
%              if decalage>0
%                 while (decalage>=0)
%                     edgeHistogramme(k-decalage)=edgeHistogramme(k+1);
%                     decalage=decalage-1;
%                 end
%             end
%         end
%         k=k+1;
%     end
%     edgeHistogramme(k+1) = 5;
    generatePeigneGaussienne;
    if ~exist('tempo', 'var')
            %% D�termination de la densit� de probabilit� des tempos
            determinationTempoV3; % Les r�sultats sont globalement bon mais il peut y avoir un �cart d'un facteur 2.
            % S�l�ection des candidats
            [~, temposCandidats]=findpeaks(C);

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
    
    %% Doublement ou division via la SVM

    
    end
    %% D�termination des dur�es de notes avec le bon tempo (normalement)
    ecartRef=60/tempo; %coefficient de normalisation des �carts
    indiceEcartsPourPeigne = findClosest(abscisse,ecart/ecartRef*4);
    
    
    
    probasEcart=peigneGaussienne(indiceEcartsPourPeigne,:);
    [~, durees] = max(probasEcart');
    
    
    if display
%         figure(1), clf
%         bar(edgeHistogramme*ecartRef, pop, 'histc')
%         hold on
%         scatter(edgeHistogramme*ecartRef, [0; probabilitesInitiales]*max(pop)/2)
        figure, clf, hold on
        stem(ecart, 'b');
        stem(durees, 'r');
        legend('Durees (en s)', 'Durees d�termin�e (en nb de double-croches)')
        plot(repmat(edgeHistogramme*ecartRef, length(ecart), 1));

    end
    
    varargout{1}=durees;
    if nargout==2        
        varargout{2}=tempo;
    end
    if nargout == 3
         varargout{2}=tempo;
        varargout{3}=svm_sum;
    end
    if nargout == 4
        varargout{2}=tempo;
        varargout{3}=svm_sum;
        varargout{4}=mult;
    end
end