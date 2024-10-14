// NK model 2 - larger file.
// This file was modified by Tomás Martinez for teaching purposes.
// Original file was written by Johannes Pfeifer to replicate ch. 3 Galí (2008).
// I cannot guarantee that it is error-free.

// Endogenous variables of the model
var pi y_gap y_nat y r_nat r_real i n a nu ;

// Exogenous shock
varexo eps_a  eps_nu;  % two shocks: technology and monetary shock


// Parameters of the model
parameters 
alpha    // capital share
beta     // discount factor
rho      // interest rate in steady state      
rho_a    // autocorrelation TFP shock
rho_nu   // autocorrelation monetary policy shock
sigma    // IES utility function
epsilon   // labor supply elasticity (frisch)
theta    // Price rigidity (calvo)
psi      // demand elasticity (intermediate goods)
phi_pi   // inflation feedback Taylor Rule
phi_y    // output feedback Taylor Rule 
;


// Calibration of parameters
sigma = 1;
epsilon=1;
phi_pi = 1.5;
phi_y  = .5/4;
theta=2/3;
rho_nu =0.5;
rho_a  = 0.9;
beta = 0.99;
alpha=1/3;
psi=6;
rho = -log(beta);



// Model equations:
model(linear);                  // the equations are linearized

//Composite parameters
#Omega=(1-alpha)/(1-alpha+alpha*psi);        
#psi_n_ya=(1+epsilon)/(sigma*(1-alpha)+epsilon+alpha); 
#lambda=(1-theta)*(1-beta*theta)/theta*Omega; 
#kappa=lambda*(sigma+(epsilon+alpha)/(1-alpha));  

pi=beta*pi(+1)+kappa*y_gap;                             // 1. New Keynesian Phillips Curve eq.
y_gap=-1/sigma*(i-pi(+1)-r_nat)+y_gap(+1);              // 2. Dynamic IS Curve eq.
i=rho + phi_pi*pi+phi_y*y_gap+nu;                       // 3. Interest Rate Rule eq.
r_nat=rho+sigma*psi_n_ya*(a(+1)-a);                     // 4. Definition natural rate of interest eq. 
r_real=i-pi(+1);                                        // 5. Definition real interest rate
y_nat=psi_n_ya*a;                                       // 6. Definition natural output
y_gap=y-y_nat;                                          // 7. Definition output gap
nu=rho_nu*nu(-1)+eps_nu;                                // 8. Monetary policy shock
a=rho_a*a(-1)+eps_a;                                    // 9. TFP shock
y=a+(1-alpha)*n;                                        // 10. Production function 
end;


steady;
check;
model_diagnostics; 
model_info;


shocks;
var eps_nu = 0.25^2; //1 standard deviation shock of 25 basis points, i.e. 1 percentage point annualized
end;

stoch_simul(order = 1,irf=15) nu i pi y_gap n y y_nat r_real r_nat;

shocks;
var eps_nu = 0;   //shut off monetary policy shock
var eps_a  = 1^2; //unit shock to technology
end;
stoch_simul(order = 1,irf=50,irf_plot_threshold=0) i pi y_gap n y y_nat r_real r_nat a ;



