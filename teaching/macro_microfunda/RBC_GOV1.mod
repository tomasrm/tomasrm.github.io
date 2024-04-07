// RBC Model with Government
// This file was modified by Tomás Martinez for teaching purposes. Original file came from Eric Sims.
// I cannot guarantee that it is error-free.

// Endogenous variables of the model
var Y C I N K R W Z G; 

// Exogenous shock
varexo ez eg;

parameters beta alpha delta phi gs ggs theta rhoz rhoG tau_k;

beta = 0.99; % discount factor
alpha = 1/3; % capital share
delta = 0.025; % depreciation rate
phi = 1; % inverse Frisch
gs = 0.2; % steady state government spending share of output
Ns = 1/3; % target Steady State labor
tau_k = 0.1; % capital tax rate 
rhoz = 0.95;
rhoG = 0.90;

% solve for SS here to get required SS theta
kns = ((1-tau_k)*alpha/(1/beta - (1-delta)))^(1/(1-alpha));
cns = (1-gs)*kns^(alpha) - delta*kns;
ks = kns*Ns;
cs = cns*Ns;
theta = (1/Ns^(phi))*(1-alpha)*kns^(alpha)/cs;
ggs = gs*kns^(alpha)*Ns;


model;
1/exp(C) = beta*(1/exp(C(+1)))*(R(+1)*(1-tau_k) + (1-delta));                     % (1) Euler equation capital
theta*exp(N)^(phi) = (1/exp(C))*exp(W);                                 % (2) Labor supply condition
exp(W) = (1-alpha)*exp(Z)*exp(K(-1))^(alpha)*exp(N)^(-alpha);           % (3) Labor demand
R = alpha*exp(Z)*exp(K(-1))^(alpha-1)*exp(N)^(1-alpha);                 % (4) Capital demand
exp(Y) = exp(Z)*exp(K(-1))^(alpha)*exp(N)^(1-alpha);                    % (5) Production function
exp(K) = exp(I) + (1-delta)*exp(K(-1));                                 % (6) Capital accumulation
exp(Y) = exp(C) + exp(I) + exp(G);                                      % (7) Resource constraint
Z = rhoz*Z(-1) + ez;                                                    % (8) Process for Z
G = (1-rhoG)*log(ggs) + rhoG*G(-1) + eg;                                % (9) Process for G


end;

steady;
shocks;
var ez = 0.01;
var eg = 0.01;
end;
stoch_simul(order=1,irf=100,ar=1);

