%%%
% gentab_all_AR.m
% Ce script teste tous les composants de l'algorithme � partir 
% d'un signal audio qu'il charge lui m�me
%


% close all
beep off

addpath(genpath('../Sources'))

%% �x�cution

disp('D: Analyse rythmique des fichiers audios (D: Display)');
disp('ND: Idem (ND: No Display)');
disp('OUT: Sortie');

D='D';
ND='ND';

OUT='OUT';
choixAlgo=input('Choix? ');


%% Onset Detection
if(~strcmp(choixAlgo, OUT)) % Dans tout les cas sauf une sortie
    disp('1: DayTripper - 8s');
    disp('2: Aller Retour Diatonique - 8s');
    disp('3: Heart & Soul - 16s');
    disp('4: No Surprises - 26s');
    disp('5: Seven Nation Army - 30s');
    disp('6: Hardest Button to Button - 35s');
    disp('7: Johnny B Good - 47s');
    disp('8: Voodoo Child - 40s');    
    disp('9:	Kashmir - 33s');
    disp('10:   Time is Running Out - 24s'); 
    disp('11:	48 notes - divers rythmes - 4m14s');
    for m=2:11

        switch(m)
            case 1                
                audioFilename='DayTripper.wav';
%                 tempo = 140;
            case 2
                audioFilename='ar-diatonique-tux.wav';
%                 tempo = 120;
            case 3
                audioFilename='heart-and-soul-tux.wav';
%                 tempo = 60;
            case 4
                audioFilename='nosurprises.wav';
%                 tempo = 72;
            case 5              
                audioFilename='seven-nation-army.wav';
%                 tempo = 120;
            case 6
                audioFilename='hardest-button.wav';
%                 tempo = 124;
            case 7
                audioFilename='Johnny_B_Good.wav';
%                 tempo = 120;
            case 8
                audioFilename='Voodoo_Child.wav';
%                 tempo = 96;
            case 9
                audioFilename='Kashmir.wav';
%                 tempo = 80;
            case 10
                audioFilename='Time_Running_Out.wav';
%                 tempo = 120;
            case 11
                audioFilename='48_dddd_cc_n_n.wav';
%                 tempo = 90;
        end
        [x,Fs]=audioread(audioFilename);
        x=x(:,1);
        if( m==1)   % Cas particulier de Day Tripper
            x=x(1:Fs*8,1);
        end
        
%         if(strcmp(choixAlgo, D))
%             figure(m),       
%         end
        OnsetDetection;   
        if(strcmp(choixAlgo, ND))
            close all
        end
        
        [segments, bornes]=segmentation(x, length(oss), sampleIndexOnsets, Fs, sampleIndexOffsets(length(sampleIndexOffsets)));
        [durees, temposDetecte(m), silences, sampleIndexOffsets] = AnalyseRythmique(oss, bornes, FsOSS, Fs, sampleIndexOnsets, sampleIndexOffsets, 0);
%         [durees, temposDetecte(m), silences, sampleIndexOffsets] = AnalyseRythmique(oss, bornes, FsOSS, Fs, sampleIndexOnsets, sampleIndexOffsets, 0, tempo);

        correctionDureeNotes
%         durees = dureesCorrigees;
        notesDet = miseEnForme(sampleIndexOnsets,  length(x)/length(oss), silences, dureesCorrigees);
%         temposDetecte(m) = tempo;
        
        [~, file, ~]=fileparts(audioFilename);
        filename = strcat('DATA/', file, '/expected.txt');

        [ecartTempo(m), tempoExp(m)]=evaluateTempo(filename, temposDetecte(m));
        [confDurees]=evaluateAR(filename, notesDet, temposDetecte(m), 0);
%         [confDurees]=evaluateAR(filename, notesDet, tempo, 0);
        succesDurees(m)=sum(diag(confDurees))/sum(sum(confDurees))*100;
    end
    
    [temposDetecte', tempoExp', ecartTempo']
    [MIN, worst] = min(temposDetecte);
    MEAN = mean(temposDetecte);
    [MAX, best] = max(temposDetecte);
  
%     disp(['Worst is n�', num2str(worst), ' with ', num2str(MIN), '%']);
%     disp(['Best is n�', num2str(best), ' with ', num2str(MAX), '%']);
%     disp(['Mean is ', num2str(MEAN), '%']);
        clear D ND OUT;
    break;
end

if(strcmp(choixAlgo, OUT))
    close all
    clear all
end