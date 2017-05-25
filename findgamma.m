function [gamma, kappa, zeta] = findgamma(n1, n2, mu_tilda, lambda_1, lambda_2, c)

p_k_n_12 = findp_k_n_12(n1, n2, mu_tilda, lambda_1, lambda_2, c);

kappa=0;
for i = 1:n1
    kappa = kappa + p_k_n_12(i);
end

zeta = 0;
for i = 1:n2
    zeta = zeta + p_k_n_12(i);
end

gamma = (kappa*lambda_1)/(kappa*lambda_1+zeta*lambda_2);

end