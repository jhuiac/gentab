%%
% peakdetectionDerivee.m
% Algorithme de d�tection de pics utilisant les d�riv�es premi�re et
% secondes, un sur-�chantillonnage par interpolation  et un �quation
% logique
%
%   ATTRIBUTS: sortie sf du spectral flux: signal 1D en fonction du temps
%   (sous-�chantillon�).
%   
%   RETURN:
%       liste des indices des pics dans le signal sur-�chantillon�

surechantillonnage=16;
sfSurechantillonne=interp(sf, surechantillonnage); %upsample x16: interpolation lin�aire
disp(['Longueur initiale de sf: ', num2str(length(sf))]);
disp(['Longueur finale de sfSurechantillone: ', num2str(length(sfSurechantillonne))]);

dsfDt=filter([1 -1], 1, sfSurechantillonne);
dsf2Dt=filter([1 -1], 1, dsfDt);  % il faut liss� cette d�riv�e qui est perturb�e par le sur-�chantillonnage

sfSurechantillonne=sfSurechantillonne(3:end);
sfSurechantillonne=sfSurechantillonne-min(sfSurechantillonne); sfSurechantillonne=sfSurechantillonne/max(sfSurechantillonne);
dsfDt=zscore(dsfDt(3:end));
dsf2Dt=zscore(dsf2Dt(3:end));
dsf2Dt=filtfilt(ones(surechantillonnage,1)/surechantillonnage, 1, dsf2Dt);


%On cherche quand la d�riv�e premi�re change brusquement de signe (max/min
%local) et que la d�riv�e seconde est n�gative (max).
%Le changement brusque de signe se traduit par une valeur dans une bande
%�troite juste au dessus de 0.
minBande=quantile(dsfDt, 0.8);
maxBande=quantile(dsfDt, 0.9);

figure(1), clf, plot([sfSurechantillonne dsfDt dsf2Dt ones(size(sfSurechantillonne))*minBande ones(size(sfSurechantillonne))*maxBande]);
legend('spectral flux', 'd�riv�e du spectral flux', 'd�riv�e seconde n�gative');

deriveeDansBande=zeros(size(sfSurechantillonne));
deriveeDansBande(dsfDt>minBande & dsfDt<maxBande)=1;

derivee2Neg=zeros(size(sfSurechantillonne));
derivee2Neg(dsf2Dt<0)=1;

peaks=deriveeDansBande & (dsf2Dt<-std(dsf2Dt)/3) & sfSurechantillonne>mean(sfSurechantillonne);
% � ce stade on a les pics mais on peut avoir plusieurs valeurs tr�s
% proches les unes des autres qui correspondent au m�me pic.
% On utilise l'�cart minimal
FsSFSurech=(length(sfSurechantillonne)/(length(x)/Fs));   %Lien entre les �chantillon du signal sf et ceux du signal "r�el" x.
ecartMinimal= round(60/960*FsSFSurech);   %ecart correspondant � 480 bpm
zoneSansPic=filter([0; ones(ecartMinimal,1)], 1, peaks);
figure(2), clf,plot([zoneSansPic>0 peaks])

peaks=peaks & ~zoneSansPic;
nbPics=length(find(peaks>0))
figure(2), clf, plot([sfSurechantillonne, peaks]);