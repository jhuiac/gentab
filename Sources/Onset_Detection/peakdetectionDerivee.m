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
sf_surechantillonne=interp(sf, surechantillonnage); %upsample x16: interpolation lin�aire
disp(['Longueur initiale de sf: ', num2str(length(sf))]);
disp(['Longueur finale de sf_surechantillone: ', num2str(length(sf_surechantillonne))]);

dsf_dt=filter([1 -1], 1, sf_surechantillonne);
dsf2_dt=filter([1 -1], 1, dsf_dt);  % il faut liss� cette d�riv�e qui est perturb�e par le sur-�chantillonnage

sf_surechantillonne=sf_surechantillonne(3:end);
sf_surechantillonne=sf_surechantillonne-min(sf_surechantillonne); sf_surechantillonne=sf_surechantillonne/max(sf_surechantillonne);
dsf_dt=zscore(dsf_dt(3:end));
dsf2_dt=zscore(dsf2_dt(3:end));
dsf2_dt=filtfilt(ones(surechantillonnage,1)/surechantillonnage, 1, dsf2_dt);


%On cherche quand la d�riv�e premi�re change brusquement de signe (max/min
%local) et que la d�riv�e seconde est n�gative (max).
%Le changement brusque de signe se traduit par une valeur dans une bande
%�troite juste au dessus de 0.
min_bande=quantile(dsf_dt, 0.8);
max_bande=quantile(dsf_dt, 0.9);

figure(1), clf, plot([sf_surechantillonne dsf_dt dsf2_dt ones(size(sf_surechantillonne))*min_bande ones(size(sf_surechantillonne))*max_bande]);
legend('spectral flux', 'd�riv�e du spectral flux', 'd�riv�e seconde n�gative');

derivee_dans_bande=zeros(size(sf_surechantillonne));
derivee_dans_bande(dsf_dt>min_bande & dsf_dt<max_bande)=1;

derivee2_neg=zeros(size(sf_surechantillonne));
derivee2_neg(dsf2_dt<0)=1;

peaks=derivee_dans_bande & (dsf2_dt<-std(dsf2_dt)/3) & sf_surechantillonne>mean(sf_surechantillonne);
% � ce stade on a les pics mais on peut avoir plusieurs valeurs tr�s
% proches les unes des autres qui correspondent au m�me pic.
% On utilise l'�cart minimal
FsSF_surech=(length(sf_surechantillonne)/(length(x)/Fs));   %Lien entre les �chantillon du signal sf et ceux du signal "r�el" x.
ecart_minimal= round(60/960*FsSF_surech);   %ecart correspondant � 480 bpm
zone_sans_pic=filter([0; ones(ecart_minimal,1)], 1, peaks);
figure(2), clf,plot([zone_sans_pic>0 peaks])

peaks=peaks & ~zone_sans_pic;
nb_pics=length(find(peaks>0))
figure(2), clf, plot([sf_surechantillonne, peaks]);