// NK model 3 
// This file was modified by Tomás Martinez for teaching purposes.
// I cannot guarantee that it is error-free.

// Endogenous variables of the model
var
y_gap                     // Output gap 
pi                        // Inflation  
i                         // Interest rate 
shockg                    // Shock: Demand Shock
shockc                    // Shock: Cost-push Shock
;


// Exogenous shock
varexo eg ec;  % two shocks: demand and cost-push (supply) shock


// Parameters of the model
parameters 
beta     // discount factor
lambda   // Slope of Phillips Curve
sigma    // IES utility function
phi_pi   // inflation feedback Taylor Rule
phi_y    // output feedback Taylor Rule 
alpha    // Loss function weight of output w.r.t inflation
rhog     // Autocorrelation of demand shock
rhoc     // Autocorrelation of cost-push shock
rho      // interest rate in steady state      
;

// Calibration of parameters
beta = 0.99;
sigma = 1;
epsilon=1;
phi_pi = 1.5;
phi_y  = 0.5;
rhog =0.9;
rhoc =0.9;
lambda=0.2;
alpha=0.5;
rho = -log(beta);


model(linear);

shockg=rhog*shockg(-1)+eg;                   // Demand shock
shockc=rhoc*shockc(-1)+ec;                   // Supply shock

y_gap=-1/sigma*(i- pi(1))+ y_gap(1) +shockg ;             // Dynamic IS
pi=lambda*y_gap+ beta*pi(1) +shockc;                          // NKPC
i=(1+(1-rhoc)*lambda/(alpha*sigma)*rhoc)*pi(1)+sigma*shockg;  // Optimal Policy
end;



steady;
check;
model_diagnostics; 
model_info;

shocks;
var ec = 0.0001;
var eg = 0.0001;
end;

stoch_simul(order = 1,irf=21); 



