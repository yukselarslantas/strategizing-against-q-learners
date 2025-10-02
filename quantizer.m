function [s] = quantizer(q,qmax,qmin,n)
    bin_len = (qmax-qmin)/n;
    s = min(n,max(1,ceil((q-qmin)/bin_len)));       
end