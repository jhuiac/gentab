%AnalyseRyhmique_old.m
%
%   COMMENTAIRES:
%       On d�finit quel �tage correspond aux doubles croches et on redescend les �tages
%       Pour arriver � celui qui correspond aux noires.
%       On calcule le tempo et on v�rifie qu'il correspond � notre intervalle [50; 150]
%       Si on est en dessous, On d�cale les �tages jusqu'� �tre dans le bon intervalle
%       Ex: si on avait trouv� la noire � 40 BPM, en multipliant par 2, on obtiendrait 80BPM ce qui est tr�s bien
%
%   R�SULTATS:
%       Fonctionne plut�t bien pour les premiers tests. La qualit� de cet
%       algo d�pend fortement de celle de l'Onset Detection.
format long
ecart=diff(bornes)/Fs;
format short
temposCandidats=(ecart./Fs);
temposCandidats=((60)./temposCandidats);

%On normalise les tempos (1/�carts) dans le domaines 4:0.5:9 environ (16BPM
% � 512 BPM)
notesNormees=0.5*round(log2(round(temposCandidats))/0.5);


%% Constitution des classes de dur�e de note avec leur population(nombre de
% notes de cette dur�e
tabClassesPop=[];
for i=[4:0.5:9]
    tabClassesPop=[tabClassesPop; i length(find(notesNormees==i))];
end

%% On cherche maintenant � d�terminer qu'elle est la dur�e musicale de 
%   chaque classe, ce qui nous permettra d'�diter la partition plus tard

%On cherche la plus haute classe qui a de la population = double croche
%A terme il faudra prendre en compte la possibilit� de triple croche?
classeDoubleCroche=max(tabClassesPop(find(tabClassesPop(:,2)>0),1));
    
%Ce tableau contiendra les diff�rents types de notes pr�sentes, leurs
%classe et leur population
listeNotesGroupees=[];
tabNomDureeNotes={['double croche'];['double croche pointee'];['croche'];['croche pointee'];['noire'];['noire pointee'];['blanche'];['blanche pointee'];['ronde']};

for(i=[1:0.5:(classeDoubleCroche-4)])
    if(tabClassesPop((classeDoubleCroche-i+1)*2-7,2)>0)
        listeNotesGroupees=vertcat(listeNotesGroupees,dataset([tabNomDureeNotes(i*2-1)], [tabClassesPop((classeDoubleCroche-i+1)*2-7,1)], [tabClassesPop((classeDoubleCroche-i+1)*2-7,2)]));
    end
end
listeNotesGroupees=set(listeNotesGroupees, 'VarNames', {['DureeDeLaNote'], ['Classe'], ['Population']});
tempo= determinationTempo( listeNotesGroupees, sort(temposCandidats))

%% Cr�ation du vecteur contenant toutes les types de notes jou�s dans l'ordre

% Une fois le tempo trouv� approximativement, on recalcule les norme des
% notes d'une mani�re plus rigoureuse connaissant le tempo (t):
%
%   r   bp  b   np  n   cp  c  dcp  dc
% |---|---|---|---|---|---|---|---|---|
%  t/4     t/2      t      2*t     4*t
%
%   On va calculer les bornes de ces classes et classifi�e les notes en
%   fonction de ces bornes (en % du tempo):
% bornesClassesNotes=[     31.25;   43.75;  62.5;  85.5; 125;   175;  250;      350      ]/100; % valeurs th�oriques
bornesClassesNotes=[     31.25;   43.75;  62.5;   93;   125;   175;    290;      290     ]/100; % valeurs modifi�es (pas de DcrochP)
%                     |rondes|blancheP|blanche|noireP|noire|crocheP|croche|DcrocheP|Dcroche|
%                        9       8        7      6      5     4       3        2      1
for i=1:length(temposCandidats)    % Pour toute les notes
    if(temposCandidats(i)<bornesClassesNotes(1)*tempo)
        listeNote(i) = 9; %ronde
    elseif(temposCandidats(i)>bornesClassesNotes(1)*tempo & temposCandidats(i)<bornesClassesNotes(2)*tempo)
        listeNote(i) = 8; %blanche point�e
    elseif(temposCandidats(i)>bornesClassesNotes(2)*tempo & temposCandidats(i)<bornesClassesNotes(3)*tempo)
        listeNote(i) = 7; % blanche
    elseif(temposCandidats(i)>bornesClassesNotes(3)*tempo & temposCandidats(i)<bornesClassesNotes(4)*tempo)
        listeNote(i) = 6; % noire point�e
    elseif(temposCandidats(i)>bornesClassesNotes(4)*tempo & temposCandidats(i)<bornesClassesNotes(5)*tempo)
        listeNote(i) = 5; % noire
    elseif(temposCandidats(i)>bornesClassesNotes(5)*tempo & temposCandidats(i)<bornesClassesNotes(6)*tempo)
        listeNote(i) = 4; % croche point�e
    elseif(temposCandidats(i)>bornesClassesNotes(6)*tempo & temposCandidats(i)<bornesClassesNotes(7)*tempo)
        listeNote(i) = 3; % croche
    elseif(temposCandidats(i)>bornesClassesNotes(7)*tempo & temposCandidats(i)<bornesClassesNotes(8)*tempo)
        listeNote(i) = 2; % double croche point�e
    else
        listeNote(i) = 1; % double croche
    end
end
%notesNormees= correctionDoubleCrochePointee( notesNormees, classeDoubleCroche, tempo, ecart, Fs );
% listeNote=[];
% for(i=[1:length(notesNormees)])
%     listeNote=[listeNote;[tabNomDureeNotes((classeDoubleCroche-notesNormees(i))*2+1)]];
% end
% listeNote