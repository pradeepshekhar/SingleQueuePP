% Find the prices corresponding to balking rates
function [P1, P2] = findprices(n1, n2, c, R1, R2, Cw, W, mu_tilde, mu1, mu2)
%W is cutoff time for parking rates


P1 = (exp(W*mu1) * mu1 * ( R1 * c * mu_tilde - Cw*(n1 - c) )...
    - exp(W*mu2) * mu2 * ( R2 * c * mu_tilde - Cw*(n2 - c) ))/...
    (c * mu_tilde * (exp(W*mu1) - exp(W*mu2) ));

P2 = ( - c * mu_tilde * P1 ...
    + exp(W*mu2) * mu2 * ( (P1-R2*mu2) * c * mu_tilde + Cw * (n2-c) ))/...
    (c * mu_tilde);


end