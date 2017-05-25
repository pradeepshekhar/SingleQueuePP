% Single lot of size c with two types of vehicles
% All prices are in $/hr
% All notations according to "Queuing framework report"

%total no. of parking spots
c=30;

% service rate in single-type vehicles case. Value in Ratliff paper: 1/2
mu = 1/2;

% Time after which users are priced more
W = 1;

% service rate for type 1 and 2 vehicles
mu_1 = mu*(1-exp(-mu*W))/(1-exp(-mu*W)-mu*W*exp(-mu*W));
mu_2 = mu/(1+mu*W);

% Common arrival rate  (per hr)
lambda = 60/5;

% arrival rate of type 1 and 2 vehicles
lambda_1 = lambda*(1-exp(-mu*W)); 
lambda_2 = lambda*exp(-mu*W);

%initial proportion of type 1 users in the lot
gamma = 0;

% average service time
mu_tilda = (mu_1*mu_2)/(gamma*mu_2 + (1-gamma)*mu_1);

%Traffic intensity
rho = lambda/(c*mu);

% parking prices (Will be changed based on balking lavel later)
P_1 = 0;
P_2 = 0; 

% Waiting cost
P_w = 30; %48 used by ratliff et al

% Reward for parking: single type, Type1 and Type2
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
lot = struct('num_spots', c, 'parking_cost_1', P_1, 'parking_cost_2', P_2);

% probability of acceptance of cars of types 1 and 2 
% assigning some initial guess of the correct values
kappa = 0; 
zeta = 0.8; 

% desired balking levels of vehicles
n1=35;
n2=60;

n1_start = 30;
n2_start = 30;
n1_range = 30;
n2_range = 30;

%Matrix to store utilities for all options of (n1,n2)
utility_total = zeros(n1_range+1,n2_range+1);
utility_1 = zeros(n1_range+1,n2_range+1);
utility_2 = zeros(n1_range+1,n2_range+1);

%Cycling through different pairs of (n1,n2) and finding utility
for n1=n1_start:n1_start+n1_range
    for n2=n2_start:n2_start+n2_range
        x = n1-n1_start+1;
        y = n2-n2_start+1;

        %x=1;y=1;
        for z=1:10
            %note: gamma stabilizing after 10 iterations
            [gamma, kappa, zeta] = findgamma(n1, n2, mu_tilda, lambda_1, lambda_2, c);
            mu_tilda = (mu_1*mu_2)/(gamma*mu_2 + (1-gamma)*mu_1);
            %disp(gamma);
        end
        
        %total utility
        utility_total(x,y) = 0;
        utility_1(x,y) = 0;
        mu_tilda = (mu_1*mu_2)/(gamma*mu_2 + (1-gamma)*mu_1);
        p_k_n_12 = findp_k_n_12(n1, n2, mu_tilda, lambda_1, lambda_2, c);
        for i=1:n1
            utility_total(x,y)=utility_total(x,y)+gamma*(lambda_1)*(p_k_n_12(i))*...
                (findalpha(i-1, users(type_1_idx), lot, mu_tilda)); 
        end
        utility_1(x,y) = utility_total(x,y)/gamma;
        
        for i=1:n2
            utility_total(x,y)=utility_total(x,y)+(1-gamma)*(lambda_2)*(p_k_n_12(i))*...
                (findalpha(i-1, users(type_2_idx), lot, mu_tilda));
        end
        utility_2(x,y) = (utility_total(x,y)-utility_1(x,y))/(1-gamma);

        gamma=0;
    end
end
[U_total_max] = max(utility_total(:));
[row, col] = find(utility_total == U_total_max);
U_1_max = utility_1(row,col);
U_2_max = utility_2(row,col);
n1_max = n1_start+row-1;
n2_max = n2_start+col-1;
figure(1);
mesh(utility_total);
%{
figure(2);
plot(p_k_n_12);
%}