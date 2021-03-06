% Etapes :
%
% 2) Pre traitement
% 3) Construction de la matrice pour conversion MIDI 
% 4) Piano Roll
% 5) Conversion MIDI

%% Pre traitement
% On considere ici une partition en 4/4
coeftmp = 120/tempo;
tempoSeconde = tempo*coeftmp/60; % bps : unite de temps
unitDuree = 1/16; % unite minimale relative par defaut : double croche = 1/4 de temps pour mesure 4/4 donc 1/4*1/4 = 1/16

FsMidi = tempoSeconde*unitDuree; % Frequence d'echantillonage pour pre traitement
nbIndTotal = length(x);
id = (0:nbIndTotal)';
t = id*FsMidi; % echelle des temps du pretraitement

%% Construction de la matrice pour conversion MIDI 
% La matrice de pre traitement (notes) est definie par rapport a la matrice
% attendue au moment de la generation du fichier MIDI.
%
% La fonction matrix2midi (provenant du projet matlab-midi :
% https://github.com/kts/matlab-midi) a besoin des infos 
% suivantes pour structurer le fichier final :
%
% 1/ track : nombre de pistes de donnees MIDI
% 2/ channel : nombre de cannaux MIDI de transmission de pistes
% 3/ numero de note : ton + 15 + octave * 12 = numero de note
% 4/ velocity : volume de la note
% 5/ "on" : debut de la note sur l'echelle des temps
% 6/ "off" : fin de la note sur l'echelle des temps

nbNotes = length(notesDet);
notes = zeros(nbNotes, 6); % matrice de pretraitement

for j = 1:nbNotes
    notes(j, 1) = 0; % Track par defaut : 1
    notes(j, 2) = 1; % Channel par defaut : 1
    notes(j, 3) = notesDet(j).convertMIDI()+12; % numero de note
    notes(j, 4) = 95; % velocity par defaut : 95
        
    if(j == 1) % instant "on" de la note
        notes(j, 5) = 0; 
    else
        notes(j, 5) = notes(j-1, 6);
    end
    
    notes(j, 6) = notes(j, 5) + notesDet(j).duree*FsMidi; % instant "off" de la note        
end

% Toutes les notes portant le numero 15 sont des silences qu'il faut
% exclure de la matrice. 
notes(find(notes(:, 3) < 0), :) = [];

% %% Piano Roll
% 
% pianoRoll = ones(size(id)).*-1;
% pianoRoll(1) = 0;
% 
% % determination de la hauteur des notes
% for n = 1:length(notesDet)
%     pianoRoll(notesDet(n).indice +1, 1) = notesDet(n).ton;
% end
% 
% % determination de la duree des notes
% for l = 1:length(pianoRoll)
%     if(pianoRoll(l) == -1)
%         pianoRoll(l) = pianoRoll(l-1);
%     end
% end
% 
% % piano roll
% % les notes a 0 representent les silences
% figure(4), clf, plot(t, pianoRoll, 'o')
% set(gca,'ytick', -1:1:13)
% axis([0 t(end) -1 13])
% grid on

% %% Piano Roll
% % compute piano-roll:
% [PR,t,nn] = piano_roll(notes);
% 
% % display piano-roll:
% figure(5);
% imagesc(t,nn,PR);
% axis xy;
% xlabel('time (sec)');
% ylabel('note number');

%% Conversion MIDI

% Generation du fichier midi
midi = matrix2midi(notes);
% nomMIDI = input('nom du fichier MIDI :', 's');
% out = strcat('DATA/', file, '/', file, '.mid')
% out = strcat('DATA/', file, '/', 'essaiAR', '.mid')

writemidi(midi, out);
