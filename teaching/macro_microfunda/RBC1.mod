// RBC Model 
// This file was written by Tomás Martinez for teaching purposes.
// I cannot guarantee that it is error-free.

// Endogenous variables of the model
var logY logC  logI logK logN logw y c k n z w r i ;

// Parameters of the model
parameters beta sigma delta alpha psi theta rho  ;

// Exogenous shock
varexo ez ;

// Calibration of parameters
beta=0.99;
sigma=1.0;
alpha=1/3;
delta=0.02;
psi = 1;
rho =0.979;
sigma_z =0.009;
kn_ss = (alpha/(1/beta - 1 + delta))^(1/(1-alpha));
cn_ss = (kn_ss)^alpha - delta*(kn_ss);
n_ss=1/3;
theta = 1/n_ss^(psi + sigma) * (1-alpha) * (cn_ss)^(-sigma) *(kn_ss)^alpha;

// Model equations:
model;
y=exp(z)*k(-1)^alpha *n^(1-alpha);                                                // Production function
c^(-sigma) = c(1)^(-sigma) * beta*(1 + r(1));                                 // Euler equation
y=c+i;                                                                      // Market clearing
theta*n^psi / c^(-sigma) = w;                                               // Labour supply decision
z=rho*z(-1) + ez;                                                 // Shock process                                                              
w=(1-alpha)*y/n;                                                            // Wages (labor demand)
r=(alpha)*y/k(-1) - delta;                                                  // Interest rate (capital demand)
i=k -(1-delta)*k(-1);                                                       // Capital law of motion

logY = log(y);
logC = log(c);
logI = log(i);
logN = log(n);
logw = log(w);
logK = log(k);

end;


steady;
check;
model_diagnostics; 
model_info;

shocks;
var ez;
stderr 0.01; // 1% shock
end;

stoch_simul(order=1, irf=200, hp_filter=1600);

