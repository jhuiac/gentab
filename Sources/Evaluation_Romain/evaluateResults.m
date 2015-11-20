function [] = evaluateResults(filepath, varargin)
%   evaluateResults.m
%   USAGE:
%       [] = evaluateResults(filepath, notes, rythme)
%       [] = evaluateResults(filepath, notes)
%       [] = evaluateResults(filepath, sample$S1ndexOnsets)
%
%   ATTRIBUTS:
%       filepath:
%           Chemin relatif du fichier audio de test. Doit finir par '\'
%       notes:
%           Liste des notes reconnues. Format 'note|#/(espace)|octave' sans
%           s�parateur
%       rythme:
%           Liste des dur�es de note reconnues. Format: cell array
%           verticale contenant le "nom" des dur�es de note.

%% V�rification sur l'argument filepath
filepath = strrep(filepath, '\', '/');  % Conversion Win -> linux
if filepath(end) ~= '/'
    filepath = [filepath '/'];
end
pattern = '/expected.txt';
if ~isdir(filepath)
    error(strcat('[ERREUR] Le dossier ', filepath, ' n''existe pas.'));
end
filename = strcat(filepath, pattern);
if ~exist(filename, 'file');
    error(strcat('[ERREUR] Le fichier ', pattern, ' n''existe pas dans ', filepath));
end
%% V�rification sur les autres arguments
% S'il y a 3 arguments, on v�rifie qu'on respecte le premier format d'usage

evaluateAR = true;
evaluateAH = true;
    
if(nargin == 3)
    if(~ischar(varargin{1}))
        error('[ERREUR] L''argument ''notes'' n''a pas le bon format');
    end
    if(~iscell(varargin{2}))
        error('[ERREUR] L''argument ''notes'' n''a pas le bon format');
    end
    notesDet = varargin{1};
    rythmeDet = varargin{2};
elseif(nargin == 2)
    if(~ischar(varargin{1}) && ~iscell(varargin{1}) && ~isreal(varargin{1}))
        error('[ERREUR] Le second argument n''a pas le bon format');
    end
    % Si l'argument est compos� de strings
    if  ischar(varargin{1})
        evaluateAR = false;
        notesDet = varargin{1};
    end
    if  iscell(varargin{1})
        evaluateAH = false;
        rythmeDet = varargin{1};
    end
    if (isreal(varargin{1}) && ~ischar(varargin{1}))
        evaluateAH = false;
        evaluateAR = false;
    end
end

if  (nargin == 2)
    if  size(notesDet, 2) ~= 3
        error('[ERREUR] L''argument ''notes'' n''a pas le bon format');
    end
end

% if(ischar(varargin{1}))
%     notesDet = varargin{1};
%     evaluateAH = true;
% elseif(isreal(varargin{1}))
%     notesDet = varargin{1};   % Il ne s'agit pas du tout des notes jou�es mais le programme s'arretera avant de d�clencher une erreur
%     evaluateAR = false;
%     evaluateAH = false;
% end


[notesExp, rythmeExp]=loadExpectedTXT(filename);

%% �valuation du nombre d'onset d�tect�
nbOnsetExp=size(notesExp, 1);
nbOnsetDet=size(notesDet, 1);
[ onsetPerformance ] = evaluateOnsets(nbOnsetExp, nbOnsetDet);

if(~evaluateAR & ~evaluateAH)
    return;
end

%% �valuation des notes d�tect�es
if(evaluateAH)
    disp(' ');
    disp('Reconnaissance des notes (tons)');
    if(strcmp(notesDet, notesExp))  % Test si tout est parfait
        disp('GOOD!: 100%!');
    else
       notesDetDouble=convert2double(notesDet);           %Conversion num�rique des mesures
       notesExpDouble=convert2double(notesExp);

       if(nbOnsetDet==nbOnsetExp)   %Cas o� le nombre de ligne est le m�me
           pourcentageOctave=sum(notesDetDouble(:,3)==notesExpDouble(:,3))/length(notesExpDouble)*100;
           disp(['D�tection des octaves = ' num2str(pourcentageOctave) '%.']);

           pourcentageFondamentales = sum((notesDetDouble(:,1)+notesDetDouble(:,2))==(notesExpDouble(:,1)+notesExpDouble(:,2)))/length(notesExpDouble)*100;
           disp(['D�tection des notes = ' num2str(pourcentageFondamentales) '%.']);
       elseif(nbOnsetDet>nbOnsetExp)    % S'il y a des notes de d�tect�es en trop
           notesOk=0;
           j=0;
           for(i=1:nbOnsetExp)  % Pour toutes les notes attendues
              if(notesDetDouble(i+j,3)==notesExpDouble(i,3) && (notesDetDouble(i+j,1)+notesDetDouble(i+j,2))==(notesExpDouble(i,1)+notesExpDouble(i,2)))
                  notesOk=notesOk+1;
              else
                  if(j<nbOnsetDet-nbOnsetExp)
                    j=j+1;
                  else
                      %warning('Trop de diff�rences pour �valuer');
                  end
              end
           end
           pourcentageCorrect = notesOk/length(notesExpDouble)*100;
           disp(['D�tection des notes et fondamentales = ' num2str(pourcentageCorrect) '%.']);
       else      
           notesOk=0;
           j=0;
           for(i=1:nbOnsetDet)
              if(notesDetDouble(i,3)==notesExpDouble(i+j,3) && (notesDetDouble(i,1)+notesDetDouble(i,2))==(notesExpDouble(i+j,1)+notesExpDouble(i+j,2)))
                  notesOk=notesOk+1;
              else
                  if(j<nbOnsetExp-nbOnsetDet)
                    j=j+1;
                  else
                      %warning('Trop de diff�rences pour �valuer');
                      break;
                  end
              end
           end
           pourcentageCorrect = notesOk/length(notesExpDouble)*100;
           disp(['D�tection des notes et fondamentales = ' num2str(pourcentageCorrect) '%.']);
       end

    end
end

%% �valuation du rythme
if(evaluateAR)
    disp(' ');
    disp('Reconnaissance du rythme (dur�e de note)');


    % Connaissant les noms des dur�es de notes, on r�cup�re un �quivalent num�rique de la
    % dur�e de la note , plus facile � comparer. (On peut se passer de cette
    % �tape si on utilise des �num�rations).
    tabNomDureeNotes={['double croche'];['double croche pointee'];['croche'];['croche pointee'];['noire'];['noire pointee'];['blanche'];['blanche pointee'];['ronde']};

    if(iscell(rythmeDet))
        [~, rythmeDetDouble] = ismember(rythmeDet, tabNomDureeNotes);
    else
        rythmeDetDouble=rythmeDet;
    end
    [~, rythmeExpDouble] = ismember(rythmeExp, tabNomDureeNotes);

    if(nbOnsetDet==nbOnsetExp)
        if(sum(rythmeExpDouble==rythmeDetDouble)==nbOnsetDet)
            disp('GOOD!: 100%!');
        else
            comparaison=abs(rythmeExpDouble-rythmeDetDouble);
            nErreurs=length(find(comparaison~=0));
            nErreursMinimes=length(find(comparaison==1));
            nErreursImportantes=length(find(comparaison>1));    %La note d�tect�s est relativement tr�s �loign�es de celle attendue (noire au lieu de croche)
            disp([num2str(nErreurs) ' erreurs trouv�es (sur ' num2str(nbOnsetDet) ' d�tect�es) dont:']);
            disp(['     ' num2str(nErreursMinimes) ' erreurs minimes']);
            disp(['     ' num2str(nErreursImportantes) ' erreurs importantes']);
        end
    else
        disp('Impossible d''analyser la correspondance du rythme');
        [val, indMax]=max(xcorr(rythmeExpDouble, rythmeDetDouble));
        decalage=indMax-length(rythmeExpDouble);
        disp(['D�calage de ' num2str(decalage) ' note(s)']);
        correlation = val/sum(rythmeExpDouble.^2);
        disp(['Corr�lation de ' num2str(correlation*100) '%']);
    end
end
end

% Calcul le taux de d�tection entre le nombre d'onset attendus et le nombre
% d'onsets d�tect�s
function [ performance ] = evaluateOnsets(nbOnsetExp, nbOnsetDet)
    disp('D�tection des onsets:');
    disp([num2str(nbOnsetDet) ' d�tect�s.']);
    disp([num2str(nbOnsetExp) ' attendus.']);

    if(nbOnsetDet<nbOnsetExp)
        disp(['/!\ :  ' num2str(nbOnsetExp-nbOnsetDet) ' onsets n''ont pas �t� detect�s!']);
        performance = (nbOnsetDet)/nbOnsetExp;
    elseif(nbOnsetDet>nbOnsetExp)
        disp(['/!\ :  ' num2str(nbOnsetDet-nbOnsetExp) ' onsets ont �t� d�tect�s en trop!']);
        performance = (2*nbOnsetExp-nbOnsetDet)/nbOnsetExp*100;
    else
        disp(['GOOD!: ' 'Tous les onsets attendus on �t� detect�s!']);
    end
    disp(['Performance: ' num2str(performance) '%']);
end

% Convertit le nom des notes du format A#2 vers A->val num�rique de ASCII
% (A), bool, num�ro d'octave
function [notesDouble] = convert2double(notesChar)
       notesDouble=double(notesChar);           %Conversion num�rique des mesures
       notesDouble(:,3)=notesDouble(:,3)-48;    % convertit la 3 colonne en le num�ro de l'octave
       notesDouble(:,2)=(notesDouble(:,2)-32)/3; % Convertit la colonne 2 en "boolean" vrai si #, 0 sinon
end