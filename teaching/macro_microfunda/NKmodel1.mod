// NK model 1 - simple file.
// This file was wirtten by Tomás Martinez for teaching purposes.
// I cannot guarantee that it is error-free.

// Endogenous variables of the model
var pi y_gap r_nat i a nu ;

// Exogenous shock
varexo eps_a  eps_nu;  % 2 shocks: technology and monetary shock


// Parameters of the model
parameters 
beta     // discount factor
rho      // interest rate in steady state   
rho_a    // autocorrelation TFP shock
rho_nu   // autocorrelation monetary policy shock
sigma    // IES utility function
epsilon  // labor supply elasticity (frisch elasticity)
theta    // Price rigidity (calvo)
phi_pi   // inflation feedback Taylor Rule
phi_y    // output feedback Taylor Rule 
;

// Calibration of parameters
sigma = 1;
epsilon = 1;
phi_pi = 1.5; 
phi_y  = .5/4;
theta=2/3;
rho_nu =0.5;
rho_a  = 0.9;
beta = 0.99;
rho = -log(beta);


// Model equations:
model(linear);                  // the equations are linearized

//Auxiliary parameters
#psi_n_ya=(1+epsilon)/(sigma+epsilon); 
#lambda=(1-theta)*(1-beta*theta)/theta; 
#kappa=lambda*(sigma+epsilon);  

pi=beta*pi(+1)+kappa*y_gap;                             // 1. New Keynesian Phillips Curve eq.
y_gap=-1/sigma*(i-pi(+1)-r_nat)+y_gap(+1);              // 2. Dynamic IS Curve eq.
i=rho+phi_pi*pi+phi_y*y_gap+nu;                          // 3. Interest Rate Rule eq.
r_nat=rho+sigma*psi_n_ya*(a(+1)-a);                     // 4. Definition natural rate of interest eq. 
nu=rho_nu*nu(-1)+eps_nu;                                // 5. Monetary policy shock
a=rho_a*a(-1)+eps_a;                                    // 6. TFP shock
end;


steady;
check;
model_diagnostics; 
model_info;


shocks;
var eps_nu = 0.25^2; //1 standard deviation shock of 25 basis points, i.e. 1 percentage point annualized
end;

stoch_simul(order = 1,irf=15) y_gap r_nat i nu;
shocks;
var eps_nu = 0;   //shut off monetary policy shock
var eps_a  = 1^2; //unit shock to technology
end;

stoch_simul(order = 1,irf=200,irf_plot_threshold=0) y_gap r_nat a i ;



