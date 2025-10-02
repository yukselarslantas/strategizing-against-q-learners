function q_hat = inverse_quantizer(s,qmax,qmin,n)
    bin_len = (qmax-qmin)/n;
    q_hat = qmin + bin_len*(s-0.5);
end