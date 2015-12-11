function [ note ] = determinationNoteSegmentOctave_convolution(x, Fs)
%determinationNoteSegmentOctave_convolution
%   D�termination d'octave par convolution avec une banque de sinus
%   (r�sonateurs)
    tabNomNotes=['E '; 'F '; 'F#'; 'G '; 'G#'; 'A '; 'A#'; 'B '; 'C '; 'C#'; 'D '; 'D#'];
    len=2^11;
    tableNotes=generateTableNotes(false);   % G�n�re dans une table, les fr�quences des notes de E2 � E6 (plus d'autres infos)

    tableNotes=tableNotes(:,:,3);
    tableNotes=tableNotes(:);
    bankOfSines= sin(2*pi*tableNotes*(0:1/Fs:len/Fs));

    for kTon=1:48
        temp=conv(x, bankOfSines(kTon,:));
        ton(kTon+1)=sum(temp.^2).*length(bankOfSines(kTon,:)); % Normalisation par le nombre d'�chantillon dans le sinus
    end

    [~, loc]=findpeaks(ton, 'NPEAKS', 1,'MINPEAKHEIGHT', mean(ton)+2*std(ton));
    h=mod(loc-1,12);
    if mod(loc-1,12)==0
        h=12;
    end
    note = [tabNomNotes(h,:) ' '];
end

