function [ note ] = determinationNoteSegmentOctave_convModele(x, Fs)
%determinationNoteSegmentOctave_convolution
%   D�termination d'octave par produit scalaire avec un mod�le
    load timbre.mat
    tabNomNotes=['E '; 'F '; 'F#'; 'G '; 'G#'; 'A '; 'A#'; 'B '; 'C '; 'C#'; 'D '; 'D#'];
    len=2^11;
    [tableNotes] = generateTableNotes(-17,42);

    tableNotes=tableNotes(:,:,3);
    tableNotes=tableNotes(:);

    if(length(x)<2^19)
        segFftWin=fft(x.*blackman(length(x)), 2^15);  %Permet d'assurer une pr�cision suffisante
    %   TODO: rendre ce paam�tre de fft d�pendant de la longueur du segment
    %   (mais toujours une puissance de 2).
    else
        segFftWin=fft(x.*blackman(length(x)));
    end
    y=length(segFftWin);
    % axe_freq = (10:y/2-1-15380)*Fs/y;
    % segFftWin=abs(segFftWin(11:(length(segFftWin)/2-15380)));
    axe_freq = (0:y/2-1)*Fs/y;
    segFftWin=abs(segFftWin(1:(length(segFftWin)/2)));
            
    for kTon=1:48
        freqSousHarmonique = tableNotes(kTon); % f0/2
        indiceSousHarmonique = findClosest(axe_freq, freqSousHarmonique); %indice de la sous harmonique dans le vecteur axe_freq
                        
        timbres(kTon,:)=sum(segFftWin(bsxfun(@plus, indiceSousHarmonique*[1, 2:2:12],(-4:4)')))./sum(segFftWin); % On cherche des pics de largeur 9 en f0/2, f0 , nf0 jusqu'� n=6
    end
    score=timbres*model';
    [~, idx]=max(score);
%     [~, loc]=findpeaks(ton, 'NPEAKS', 1,'MINPEAKHEIGHT', mean(ton)+2*std(ton));
    h=mod(idx-1,12)+1;
    note = [tabNomNotes(h,:) ' '];
end

