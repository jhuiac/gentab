function CD_out=phase_deviation(stft,fMin,fMax,Fs,N)

            % Cette fonction retourne un vecteur de nImages, contenant l'onset detection
            % dans le signal entre fMin et fMax en utilisant la deviation
            % de phase
           
            IFmin = max(1,round(fMin/Fs*N)); % fmin r�duite au fen�trage de hamming
            IFmax = round(min(fMax/2,fMax/Fs*N));% fmax r�duite au fen�trage de hamming
            
            SignalFrame = stft(IFmin:IFmax,:); % on prend la transform�e de fourier dans la fr�quence r�duite
            
            TailleFenetrage = size(SignalFrame,1); % nombre de fr�quences 
            Nbre = size(SignalFrame,2); % nombre d'indices (temps)
            
            Phi = (angle(SignalFrame(:,:))); % on calcule toutes les phases de toutes les fr�quences du signal
            Phi_renverse=Phi';
            Phi_derive_temp= diff(Phi_renverse); 
            Phi_derive=[Phi_derive_temp' zeros(TailleFenetrage,1)]; % d�riv�e premi�re de la phase
            Phi_derive_temp=Phi_derive';
            Phi_derive_temp_deux= diff(Phi_derive_temp);
            Phi_derive_2=Phi_derive_temp_deux';
            Phi_derive_2=[Phi_derive_2 zeros(TailleFenetrage,1)];

           
            for n=1:TailleFenetrage            
              ph_d=1/N.*abs(Phi_derive_2(n,:));
              %ph_d=abs(SignalFrame(n,:).*Phi_derive_2(n,:))./abs(SignalFrame(n,:));
            end 
   
           CD_out=ph_d';
end


