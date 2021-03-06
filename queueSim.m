% Single lot of size c with two types of vehicles
% All prices are in $/hr
% All notations according to "Queuing framework report"
clear all;clc;

%total no. of parking spots
c=50;

% service rate in single-type vehicles case. Value in Ratliff paper: 1/2
mu = 1/2;

% Time after which users are priced more
W = 1;

% service rate for type 1 and 2 vehicles
mu_1 = mu*(1-exp(-mu*W))/(1-exp(-mu*W)-mu*W*exp(-mu*W));
mu_2 = mu/(1+mu*W);

% Common arrival rate  (per hr)
lambda = 100/5;

% arrival rate of type 1 and 2 vehicles
lambda_1 = lambda*(1-exp(-mu*W)); 
lambda_2 = lambda*exp(-mu*W);

%initial proportion of type 1 users in the lot
gamma = 0;

% average service time
mu_tilde = (mu_1*mu_2)/(gamma*mu_2 + (1-gamma)*mu_1);

%Traffic intensity
rho = lambda/(c*mu);

% Waiting cost
P_w = 75; %48 used by ratliff et al

% Reward for parking for Type1 and Type2
R = 75;
R_1 = 75; R_2 = 75;
%R_1 = R*lambda*(mu_2)/(lambda_1*mu_2+lambda_2*mu_1); R_2 = R*lambda*(mu_1)/(lambda_1*mu_2+lambda_2*mu_1); 

% Created for indexing structures
type_1_idx = 1;
type_2_idx = 2;

% Create an array of structures describing type 1 and 2 users
type_1 = struct('reward', R_1, 'waiting_cost', P_w, 'arrival_rate', ...
    lambda_1, 'departure_rate', mu_1);
type_2 = struct('reward', R_2, 'waiting_cost', P_w, 'arrival_rate', ...
    lambda_2, 'departure_rate', mu_2);

users = [type_1, type_2];

% Note - P, P_1 and P_2 are changed dynamically to get the required balking
% level. So, why create a structure with them? 
lot = struct('num_spots', c, 'parking_cost_1', 0, 'parking_cost_2', 0);

% probability of acceptance of cars of types 1 and 2 
% assigning some initial guess of the correct values
kappa = 0; 
zeta = 0.8; 

% desired balking levels of vehicles
n1_start = c;
n2_start = c;
n1_range = 40;
n2_range = 40;

%Matrix to store utilities for all options of (n1,n2)
utility_total = zeros(n1_range+1,n2_range+1);
utility_1 = zeros(n1_range+1,n2_range+1);
utility_2 = zeros(n1_range+1,n2_range+1);

gamma_grid = zeros(n1_range+1, n2_range+1);
kappa_grid = zeros(n1_range+1, n2_range+1);
zeta_grid = zeros(n1_range+1, n2_range+1);
mutilde_grid = zeros(n1_range+1, n2_range+1);
p_k_n_12_grid = zeros(n1_range+1, n2_range+1, max(n1_range, n2_range)+1);

p1_grid = zeros(n1_range+1, n2_range+1);
p2_grid = zeros(n1_range+1, n2_range+1);

%Cycling through different pairs of (n1,n2) and finding utility
for n1=n1_start:n1_start+n1_range
    for n2=n2_start:n2_start+n2_range
        x = n1-n1_start+1;
        y = n2-n2_start+1;

        %x=1;y=1;
        for z=1:10
            %note: gamma stabilizing after 10 iterations
            [gamma, kappa, zeta] = findgamma(n1, n2, mu_tilde, lambda_1, lambda_2, c);
            mu_tilde = (mu_1*mu_2)/(gamma*mu_2 + (1-gamma)*mu_1);
            %disp(gamma);
        end
        
        %total utility
        utility_total(x,y) = 0;
        utility_1(x,y) = 0;
        mu_tilde = (mu_1*mu_2)/(gamma*mu_2 + (1-gamma)*mu_1);
        p_k_n_12 = findp_k_n_12(n1, n2, mu_tilde, lambda_1, lambda_2, c);
        
        
        % Keep track of these levels
        gamma_grid(x,y) = gamma;
        kappa_grid(x,y) = kappa;
        zeta_grid(x,y) = zeta;
        mutilde_grid(x,y) = mu_tilde;
        
        for i = 1:n1
            alpha_1(i) = findalpha(i-1, users(type_1_idx), lot, mu_tilde);
        end
        
        % Calculate utility from type 1 and type 2 separately
        for i = 1:n1
            utility_1(x,y) = utility_1(x,y)+ p_k_n_12(i) * ...
                findalpha(i-1, users(type_1_idx), lot, mu_tilde);
        end
%         utility_1(x,y) = utility_1(x,y) * gamma * lambda_1;
         utility_1(x,y) = utility_1(x,y) * lambda_1;
        

        for i = 1:n2
            utility_2(x,y) = utility_2(x,y) +  p_k_n_12(i) * ...
                findalpha(i-1, users(type_2_idx), lot, mu_tilde);
        end
        %utility_2(x,y) = utility_2(x,y) * (1 - gamma) * lambda_2;
        utility_2(x,y) = utility_2(x,y) * lambda_2;
        
        utility_total(x,y) = utility_1(x,y) + utility_2(x,y);
        
        [P1, P2] = findprices(n1, n2, c, R_1, R_2, P_w, W, mu_tilde, mu_1, mu_2);
        p1_grid(x,y) = P1;
        p2_grid(x,y) = P2;
        
        % Calculate utility together
%         for i=1:n1
%             utility_total(x,y)=utility_total(x,y)+gamma*(lambda_1)*(p_k_n_12(i))*...
%                 (findalpha(i-1, users(type_1_idx), lot, mu_tilde)); 
%         end
%         utility_1(x,y) = utility_total(x,y)/gamma;
%         
%         for i=1:n2
%             utility_total(x,y)=utility_total(x,y)+(1-gamma)*(lambda_2)*(p_k_n_12(i))*...
%                 (findalpha(i-1, users(type_2_idx), lot, mu_tilde));
%         end
%         utility_2(x,y) = (utility_total(x,y)-utility_1(x,y))/(1-gamma);
        gamma=0;

    end
end


[U_total_max] = max(utility_total(:));
[row, col] = find(utility_total == U_total_max);
U_1_max = utility_1(row,col);
U_2_max = utility_2(row,col);
n1_max = n1_start+row-1;
n2_max = n2_start+col-1;

%{
figure(1);
mesh(utility_total);
xlabel('type 2 balking rate');
ylabel('type 1 balking rate');
zlabel('utility');

figure(2);
plot(p_k_n_12);
%}

[p1_grid(row,col), p2_grid(row,col)]
pos_prices = (p1_grid > 0) & (p2_grid > 0);
util_feas = utility_total .* pos_prices; 
util_feas_max =  max(util_feas(:));

%Finding feasible region for one price
OnePrice_feas = zeros(n1_range+1, n2_range+1);
for i=1:n1_range
    for j=1:n2_range
        if(pos_prices(i,j)==1)
            n1 = n1_start+i-1;
            n2 = n2_start+j-1;
            %Check if there exists a P satisfying both the balking levels
            if(((mu_1*R_1-mu_2*R_2)>(P_w/(c*mutilde_grid(i,j))*((mu_1*(n1-c))-(mu_2*(n2-c+1)))))&&((mu_2*R_2-mu_1*R_1)>(P_w/(c*mutilde_grid(i,j))*((mu_2*(n2-c))-(mu_1*(n1-c+1))))))
                OnePrice_feas(i,j) = 1;
            end
        end
    end
end
Util_feas_OnePrice = utility_total .* OnePrice_feas;
Util_feas_OnePrice_max = max(Util_feas_OnePrice(:));
[row, col] = find(utility_total == util_feas_max);
U_1_feas_max = utility_1(row,col);
U_2_feas_max = utility_2(row,col);
n1_feas_max = n1_start+row-1;
n2_feas_max = n2_start+col-1;
P1_feas_max = p1_grid(row,col);
P2_feas_max = p2_grid(row,col);

figure(2); clf;
subplot(2,1,1);
mesh(utility_total);
xlabel('type 2 balking rate');
ylabel('type 1 balking rate');
zlabel('utility');
title('Utility for all balking rates');

subplot(2,1,2);
mesh(util_feas);
xlabel('type 2 balking rate');
ylabel('type 1 balking rate');
zlabel('utility');
title('Utility for feasible balking rates');

figure(3); clf
mesh(util_feas); hold on
mesh(OnePrice_feas .* 2000);
xlabel('type 2 balking rate');
ylabel('type 1 balking rate');
zlabel('utility');
title('Utility for feasible balking rates');

figure(4); clf;
mesh(p1_grid); hold on
mesh(p2_grid);