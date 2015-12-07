function [ notesDet ] = miseEnForme(sampleIndexOnsets,  FsSF, durees, notesJouees)
%miseEnForme.m
%   USAGE:
%       [ notesDet ] = miseEnForme(sampleIndexOnsets,  FsSF, durees, notesJouee)
%       [ notesDet ] = miseEnForme(sampleIndexOnsets,  FsSF, durees)
%       [ notesDet ] = miseEnForme(sampleIndexOnsets,  FsSF, notesJouee)
%       [ notesDet ] = miseEnForme(sampleIndexOnsets,  FsSF)

%	ATTRIBUTS:    
%       notesDet:   Vecteur d'objets Note compl�t� avec les r�sultats
%       disponibles
%   
%       sampleIndexOnsets:  Indice du d�but des note dans la base de STFT
%       FsSF:               Rapport entre base d'�chantillonnage et base STFT
%       durees:             vecteur contenant les dur�es des notes au format 1:16
%       notesJouee:         Vecteur contenant les dur�es des notes au format A#2
%    
%	DESCRIPTION:   
%       Rempli un objet Note pour chaque triplet Onset+dur�es+ton sauf si
%       certaine variable ne sont pas disponibles
%	BUT:    
%       Mettre en forme les donn�es avant g�n�ration de sortie

    if nargin==3
        if isa(durees, 'char')
            notesJouees = durees;
            clear durees;
        end
    end

    if ~exist('durees', 'var')
        durees=ones(length(sampleIndexOnsets)-1, 1);
    end

    if ~exist('notesJouees', 'var')
        notesJouees=repmat('E 2',length(sampleIndexOnsets)-1, 1);
    end

    for k = 1:length(durees)
       notesDet(k)=Note(round(sampleIndexOnsets(k)*FsSF), durees(k), notesJouees{k}); 
    end

end

