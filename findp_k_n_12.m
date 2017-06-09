 %Fuction for finding the stationary distribution of Queue 2 (note: It also works for n1=n2)
function p_k_n_12 = findp_k_n_12(n1, n2, mu_tilde, lambda_1, lambda_2, c)
n=max(n1,n2);
n_tilde=min(n1,n2);
p_k_n_12=zeros(1,n+1);
d_k=zeros(1,n+1);
D_n=0;
for i=1:n+1
    d_k(i) = findd_k(i-1,n_tilde,mu_tilde, lambda_1, lambda_2, c, n2<n1);
    D_n = D_n+d_k(i);
end
for i=1:n+1
    p_k_n_12(i) = d_k(i)/D_n;
end
end

function d_k = findd_k(k, n_tilde, mu_tilde, lambda_1, lambda_2, c, first)
lambda_tilde = lambda_1 + lambda_2;
rho_tilde=lambda_tilde/(c*mu_tilde);
%first is assigned 1 if n2<n1
if first
    rho_hat = (lambda_1)/(c*mu_tilde);
else 
    rho_hat = (lambda_2)/(c*mu_tilde);
end
if k<c
    d_k = ((rho_tilde*c)^k)/factorial(k);
elseif k<n_tilde
    d_k = ((rho_tilde*c)^c)*((rho_tilde)^(k-c))/factorial(c);
else
    d_k = ((rho_tilde*c)^n_tilde)*((rho_hat)^(k-n_tilde))/(factorial(c)*(c^(n_tilde-c)));
end
end