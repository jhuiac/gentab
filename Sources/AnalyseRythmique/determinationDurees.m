function [out] = determinationDurees(dureesMesurees, peigneGaussienne, abscisse)
%%
% Cette fonction determine les deux meilleures durees normalis�es (une 
% inf�rieure et une sup�rieure) suivant leur probabilit�s a partir de 
% durees mesur�es.
% 
% input  : 
%        dureesMesurees   : durees mesurees en sortie de l'onset detection
%        peigneGaussienne : probabilit�s d'apparition de chaque duree 
%                           normalis�e suivante la duree mesuree
%        abscisse         : abscisses faisant le lien entre les indices des
%                           durees mesurees et leur probabilit�s (Peigne)
%
% output :
%        out : matrice de sortie se presentant de la maniere suivante 
%
%   out(:, 1) = durees mesurees
%   out(:, 2) = durees inferieures normalis�es (DIN)
%   out(:, 1) = probabilit�s des DIN
%   out(:, 1) = durees superieures normalis�es (DSN)
%   out(:, 1) = proba des DSN
%
out = zeros(length(dureesMesurees), 5);

out(:, 1) = dureesMesurees;

out(:, 2) = floor(dureesMesurees);

for m = 1:length(dureesMesurees)
    % on cherche l'indice correspondant a la duree mesuree dans le peigne
    % de gaussienne. c'est le vecteur abscisse qui s'occupe de faire le
    % lien entre les deux.
    % On cherche l'indice correspondant entre abscisse et dureesMesurees
    [c index(m)] = min(abs(abscisse-dureesMesurees(m)));
    
    % Si on tombe sur une probabilit� de duree normalis�e = 0, on va voir
    % la probabilit� de la DIN suivante, et ainsi de suite jusqu'a 0;
    if(peigneGaussienne(index(m), out(m, 2)) ~= 0)
        out(m, 3) = peigneGaussienne(index(m), out(m, 2));
    else
        g = 1;
        while((peigneGaussienne(index(m), out(m, 2)) == 0) ...
            && (out(m, 2) > 0))
            out(m, 2) = out(m, 2) - g;
        end
        out(m, 3) = peigneGaussienne(index(m), out(m, 2));
    end
end

out(:, 4) = floor(dureesMesurees) + 1;

% memes operations que dans la premiere boucle for mais pour gerer cette 
% fois-ci les DSN 
for m = 1:length(dureesMesurees)
    [c index(m)] = min(abs(abscisse-dureesMesurees(m)));
    if(peigneGaussienne(index(m), out(m, 4)) ~= 0)
        out(m, 5) = peigneGaussienne(index(m), out(m, 4));
    else
        h = 1;
        while((peigneGaussienne(index(m), out(m, 4)) == 0) ...
            && (out(m, 4) < 16))
            out(m, 4) = out(m, 4) + h;
        end
        out(m, 5) = peigneGaussienne(index(m), out(m, 4));
    end
end


end

