 %Fuction for finding the stationary distribution of Queue 2 (note: It also works for n1=n2)
function p_k_n_12 = findp_k_n_12(n1, n2, mu_tilda, lambda_1, lambda_2, c)
n=max(n1,n2);
n_tilda=min(n1,n2);
p_k_n_12=zeros(1,n+1);
d_k=zeros(1,n+1);
D_n=0;
for i=1:n+1
    d_k(i) = findd_k(i-1,n_tilda,mu_tilda, lambda_1, lambda_2, c, n2<n1);
    D_n = D_n+d_k(i);
end
for i=1:n+1
    p_k_n_12(i) = d_k(i)/D_n;
end
end

function d_k = findd_k(k, n_tilda, mu_tilda, lambda_1, lambda_2, c, first)
lambda_tilda = lambda_1 + lambda_2;
rho_tilda=lambda_tilda/(c*mu_tilda);
%first is assigned 1 if n2<n1
if first
    rho_hat = (lambda_1)/(c*mu_tilda);
else 
    rho_hat = (lambda_2)/(c*mu_tilda);
end
if k<c
    d_k = ((rho_tilda*c)^k)/factorial(k);
elseif k<n_tilda
    d_k = ((rho_tilda*c)^c)*((rho_tilda)^(k-c))/factorial(c);
else
    d_k = ((rho_tilda*c)^n_tilda)*((rho_hat)^(k-n_tilda))/(factorial(c)*(c^(n_tilda-c)));
end
end