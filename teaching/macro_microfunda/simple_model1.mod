// Very Simple Stochastic Growth Model 1
// This file was written by Tomás Martinez for teaching purposes.
// I cannot guarantee that it is error-free.

// The dynare script will not read this comment
% The dynare script will not read this comment
/* The dynare script will not read this comment */

// Endogenous variables of the model
var z c k r;  // recall we must finish the commands with semi-colon ;

// Exogenous shock 
varexo ez ;  // Note: this is the variable we will shock to create an impulse response function

// Parameters of the model
parameters beta delta alpha rho ; 

// Calibration of parameters
beta=0.99;
alpha=1/3;
delta=0.02;
rho =0.979;


// Model equations:
model;
1/exp(c) = 1/ exp(c(1)) * beta*(1 - delta + r(1));                         // Euler equation
exp(z)*exp(k(-1))^alpha = exp(c) + exp(k) -(1-delta)*exp(k(-1));           // Market clearing  
r = alpha*exp(z)*exp(k(-1))^(alpha-1);                                     // Interest rate            
z=rho*z(-1) + ez;                                                          // Shock process                                                                              
end;

// Note the Dynare notation: the predetermined variable (such as capital) should be written as 

initval ; // Optional: this is the initial guess to the algorithm that computes the steady state of the model
z=1; k=10; c = 1.5; r = 0.05;
end ;

steady; // This computes the steady state of the model numerically. 

// alternatively, we can provide the actual steady state values if we are able to compute them analytically.
// We can do that writing:
//steady_state_model ;
//k = (alpha/(1/beta - 1 + delta))^(1/(1-alpha));
//c = (alpha/(1/beta - 1 + delta))^(alpha/(1-alpha))  - delta*(alpha/(1/beta - 1 + delta))^(1/(1-alpha));
//end ;

check;  // Verifies that the model has a stable solution. Recall that not all models have stabel solutions.
model_diagnostics; // Optional: output some diagnostic and model information.
model_info;

shocks;
var ez;       // This is our exogenous variable;
stderr 0.01; // This is the standard deviation of the shock. 
            // Dynare gives the model a one standard deviation shock to the model. 
            // Sometimes it is useful to assign the value as 0.01, so the shock is a 1% TFP shock. 
end;

stoch_simul(order=1, irf=200);


// Simulate the model with other alpha:
alpha=0.2;
stoch_simul(noprint,order=1, irf=0);

alpha=0.5;
stoch_simul(noprint,order=1, irf=0);
