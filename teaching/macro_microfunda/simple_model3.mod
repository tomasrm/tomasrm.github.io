// Very Simple Stochastic Growth Model 3
// This file was written by Tomás Martinez for teaching purposes.
// I cannot guarantee that it is error-free.

// Endogenous variables of the model
var z c k r logC logK; 

// Parameters of the model
parameters beta delta alpha rho ; 

// Exogenous shock 
varexo ez ; 

// Calibration of parameters
beta=0.99;
alpha=1/3;
delta=0.02;
rho =0.979;


// Model equations:
model;
1/c = 1/ c(1) * beta*(1 - delta + alpha*exp(z(1))*k^(alpha-1));                  // Euler equation
exp(z)*k(-1)^alpha = c + k -(1-delta)*k(-1);                                // Market clearing                                    
r = alpha*exp(z)*exp(k(-1))^(alpha-1);                                      // Interest rate            
z=rho*z(-1) + ez;                                                           // Shock process                                                                              
logC = log(c);
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

stoch_simul(order=1, irf=200);

