function [] = evaluateResults(path, varargin)
%   evaluateResults.m
%   USAGE:
%       [] = evaluateResults(path, notes, rythme)
%       [] = evaluateResults(path, sample_index_onsets)
%       [] = evaluateResults(path, notes, rythme)

%   ATTRIBUTS:
%       path:
%           Chemin relatif du fichier audio de test. Doit finir par '\'
%       notes:
%           Liste des notes reconnues. Format 'note|#/(espace)|octave' sans
%           s�parateur
%       rythme:
%           Liste des dur�es de note reconnues. Format: cell array
%           verticale contenant le "nom" des dur�es de note.
if(nargin == 3)
    rythmeDet = varargin{2};
    evaluate_AR = true;
else
    evaluate_AR = false;
end

if(ischar(varargin{1}))
    notesDet = varargin{1};
    evaluate_AH = true;
elseif(iscell(varargin{1}))
    rythmeDet = varargin{1};
    evaluate_AH = false;
    evaluate_AR = true;
elseif(isreal(varargin{1}))
    notesDet = varargin{1};   % Il ne s'agit pas du tout des notes jou�es mais le programme s'arretera avant de d�clencher une erreur
    evaluate_AR = false;
    evaluate_AH = false;
end

pattern = 'expected.txt';
[notesExp, rythmeExp]=loadExpectedTXT([path pattern]);

clc
%% �valuation du nombre d'onset d�tect�
nbOnsetExp=length(notesExp);
nbOnsetDet=length(notesDet);
[ onset_performance ] = evaluate_onsets(nbOnsetExp, nbOnsetDet);

if(~evaluate_AR & ~evaluate_AH)
    return;
end
%% �valuation des notes d�tect�es
if(evaluate_AH)
    disp(' ');
    disp('Reconnaissance des notes (tons)');
    if(strcmp(notesDet, notesExp))
        disp('GOOD!: 100%!');
    else
       notesDouble=double(notesDet);           %Conversion num�rique des mesures
       notesExpDouble=double(notesExp);

       if(nbOnsetDet==nbOnsetExp)   %Cas o� le nombre de ligne est le m�me
           pourcentageOctave=sum(notesDouble(:,3)==notesExpDouble(:,3))/length(notesExpDouble)*100;
           disp(['D�tection des octaves = ' num2str(pourcentageOctave) '%.']);

           pourcentageFondamentales = sum((notesDouble(:,1)+notesDouble(:,2))==(notesExpDouble(:,1)+notesExpDouble(:,2)))/length(notesExpDouble)*100;
           disp(['D�tection des notes = ' num2str(pourcentageFondamentales) '%.']);
       elseif(nbOnsetDet>nbOnsetExp)
           notesOk=0;
           j=0;
           for(i=1:nbOnsetExp)
              if(notesDouble(i+j,3)==notesExpDouble(i,3) && (notesDouble(i+j,1)+notesDouble(i+j,2))==(notesExpDouble(i,1)+notesExpDouble(i,2)))
                  notesOk=notesOk+1;
              else
                  if(j<nbOnsetDet-nbOnsetExp)
                    j=j+1;
                  else
                      error('Trop de diff�rences pour �valuer');
                  end
              end
           end
           pourcentageCorrect = notesOk/length(notesExpDouble)*100;
           disp(['D�tection des notes et fondamentales = ' num2str(pourcentageCorrect) '%.']);
       else      
           notesOk=0;
           j=0;
           for(i=1:nbOnsetDet)
              if(notesDouble(i,3)==notesExpDouble(i+j,3) && (notesDouble(i,1)+notesDouble(i,2))==(notesExpDouble(i+j,1)+notesExpDouble(i+j,2)))
                  notesOk=notesOk+1;
              else
                  if(j<nbOnsetExp-nbOnsetDet)
                    j=j+1;
                  else
                      warning('Trop de diff�rences pour �valuer');
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
if(evaluate_AR)
    disp(' ');
    disp('Reconnaissance du rythme (dur�e de note)');


    % Connaissant les noms des dur�es de notes, on r�cup�re un �quivalent num�rique de la
    % dur�e de la note , plus facile � comparer. (On peut se passer de cette
    % �tape si on utilise des �num�rations).
    tab_nom_duree_notes={['double croche'];['double croche pointee'];['croche'];['croche pointee'];['noire'];['noire pointee'];['blanche'];['blanche pointee'];['ronde']};
    for i=1:length(tab_nom_duree_notes)
        nomDureeDouble(i)=sum(double(tab_nom_duree_notes{i}));
    end
    nomDureeDouble=nomDureeDouble';

    for i=1:length(rythmeDet)
        rythmeDetDouble(i)=sum(double(rythmeDet{i}));
    end
    rythmeDetDouble=rythmeDetDouble';
    [~, rythmeDetDouble] = ismember(rythmeDetDouble, nomDureeDouble);

    for i=1:length(rythmeDet)
        rythmeExpDouble(i)=sum(double(rythmeExp{i}));
    end
    rythmeExpDouble=rythmeExpDouble';
    [~, rythmeExpDouble] = ismember(rythmeExpDouble, nomDureeDouble);

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
        %Trouver quelqurechose ici
        %plot(xcorr(rythmeExpDouble, rythmeExpDouble)/sum(rythmeExpDouble.^2));
    end
end
end

function [ performance ] = evaluate_onsets(nbOnsetExp, nbOnsetDet)
    disp('D�tection des onsets:');
    disp([num2str(nbOnsetDet) ' d�tect�s.']);
    disp([num2str(nbOnsetExp) ' attendus.']);

    if(nbOnsetDet<nbOnsetExp)
        disp(['/!\ :  ' num2str(nbOnsetExp-nbOnsetDet) ' onsets n''ont pas �t� detect�s!']);
        performance = (nbOnsetDet)/nbOnsetExp;
    elseif(nbOnsetDet>nbOnsetExp)
        disp(['/!\ :  ' num2str(nbOnsetDet-nbOnsetExp) ' onsets ont �t� d�tect�s en trop!']);
        performance = (2*nbOnsetExp-nbOnsetDet)/nbOnsetExp;
    else
        disp(['GOOD!: ' 'Tous les onsets attendus on �t� detect�s!']);
    end
    disp(['Performance: ' num2str(performance) '%']);
end
