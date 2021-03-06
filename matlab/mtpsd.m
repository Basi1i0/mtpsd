function [S, f, Sc] = mtpsd(x, NW, ntaper, NFFT, method, pconf)
%Computes the two-sided multi-taper power spectral density
% Inputs:
%   x the data
%   NW time-bandwidth product (2.5 is a good value)
%   ntaper number of tapers (2*NW-1 is good)
%   NFFT number of points to use for FFT
%   method equal, eigen or adapt for weighting
%   pconf confidence probability

% Outputs:
%   S the power spectral density
%   f the frequencies
%   Sc confidence intervals
    
    switch(nargin)
        case 1
            method='adapt';
            NW=4;
            ntaper=2*NW-1;
        case 2
            method='adapt';
            ntaper=2*NW-1;
        case 3
            method='adapt';
        case 4
            method='adapt';
        case 5
        otherwise
            disp('Invalid number of arguments.');
            return;
    end
    
    N=length(x);        
    
    if (nargin < 6)
        pconf = 0.98;
    end
    if (isempty(NFFT))
        NFFT = N;
    end
    
    if (size(x,1)==1)
        x=transpose(x);     %don't want to change complex component
    end
    
    repk=ones(1,ntaper);            %used for duplicating vector in ntaper columns
    repn=ones(N,1);                 %used for duplicating vector in N rows
    reps=ones(NFFT,1);              %used for duplicating vector in NFFT rows
    
    [h,l]=dpss(N,NW,ntaper);        %Data taper
    
    f = linspace(0, 1, NFFT+1);
    f = f(1:end-1);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Remove Mean to reduce bias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    m=mean(x);                      %DC component
    xx=x*repk;

    %Calculate weighted means
    leven=1:2:ntaper;               %zero out the mean for even DPSS to prevent leakage
    wm=m*repk;
    wm(leven)=sum(xx(:,leven).*h(:,leven),1)./sum(h(:,leven),1);

    xx=( xx - repn*wm );
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Calculate Eigenspectra
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Window series
    cwx=h.*xx;

    %Fourier, normalized
    Jk=fft(cwx,NFFT,1);
    Jk=Jk/sqrt(N);              %normalized so independent of N
    Jk(1,:)=m;                  %replace mean
    
    %Calculate Power
    Sk=abs(Jk).^2;     

    
    if (strcmp(method,'equal')==1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Unit Weighting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        wk=reps*ones(1,ntaper)/ntaper;    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Weight by energy concentrations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (strcmp(method,'eigen')==1)
        
        wk=reps*(l'/sum(l));   
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Adaptive Weighting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    else
        
        %Weight adaptively
        tol=0.000001;

        sigma2= sum(abs(x-m).^2)/N;             %estimated variance
        S=(Sk(:,1)+Sk(:,2))/2;               %use first two windows only as initial estimate (has best sidelobe properties)    
        Slast=zeros(size(S));

        while ( norm(S-Slast)>tol)
            Slast=S;                                    %store previous estimate
            b = S*repk./(S*l'+reps*(1-l)'*sigma2);      %denominator *should* never be zero
            b2=b.^2;
            b2l=(b2*l);
            
            % if all weights for a given f are zero (i.e. S(f)==0 ),
            % we should restore unit weights
            b2(b2l==0,:)=1; b2l(b2l==0)=ntaper;   
            wk=b2.*(reps*(l')) ./ (b2l*repk);
            S=sum(wk.*Sk,2);
        end
       
    end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Power Estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    S=sum(wk.*Sk,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Confidence intervals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (nargout > 2)

        p=(1-pconf)/2;
        v=2./sum(wk.^2,2);  

        %correct degrees of freedom at zero and fn
    %     v(1)=v(1)/2;
    %     if (mod(NFFT,2)==0)
    %         v(NFFT/2+1)=v(NFFT/2+1)/2;
    %     end

        Ql=chisqinv(p,v);
        Qu=chisqinv(1-p,v);

        Sl=v.*S./Qu;
        Su=v.*S./Ql;

        Sc=[Sl Su];
        
    end
end
