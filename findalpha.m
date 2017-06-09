function alpha = findalpha(k, user_params, lot_params, mu_tilde) 

c = lot_params.num_spots;
R = user_params.reward;
P_w = user_params.waiting_cost;

if k<c
    alpha = R;
else
    alpha = R - (P_w*(k-c+1))/(c*mu_tilde);
end