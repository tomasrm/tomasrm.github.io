// DMP Model - Model Eq. Value functions
// This file was written by Tomás Martinez for teaching purposes.
// I cannot guarantee that it is error-free.

// Endogenous variables of the model
var
theta                   // Tightness
u                       // Unemployment rate
v                       // Vacancies
q                       // Vacancy filling probability
f                       // Job finding probability
W                       // Value W
U                       // Value U
J                       // Value of a Job
w                       // Wage rate
z                       // Productivity
;

// Parameters of the model
parameters
b                       // Unemployment benefits                  
sigma                  // Separation rate
gamma                       // Bargaining power of workers
kappa                       // Cost of posting vacancies
beta                    // Discount factor
chi                      // Matching efficiency
eta                     // Matching elasticiy
rho                     // Autocorrelation of shocks
zbar                    // Productivity in steady-state
;


// Exogenous shock
varexo ez;

// Calibration of parameters
b = 0.4;             
sigma =0.10;  
gamma  = 0.72;
eta  = 0.72; 
kappa  = 0.213; 
beta = 0.99; 
chi   = 1.355; 
rho  = 0.878; 
zbar=1;

// Model equations:
model;
u=u(-1)*(1-f)+sigma*(1-u(-1));     // Beveridge Curve
theta=v/u(-1);                      // Tightness 
f=chi*theta^(1-eta);                 // job filling prob
q=chi*theta^(-eta);                    // Vacancy filling prob
W=w+beta*((1-sigma)*W(1)+sigma*U(1));  // Value of Working
U=b+beta*(f*W(1)+(1-f)*U(1));            // Value of Unemployment
J=z-w+beta*(1-sigma)*J(1);               // Value of a Job
W-U=gamma*(W-U+J);                           // Nash Bargaining
kappa=beta*q*J(1);                              // Free Entry
log(z)=(1-rho)*log(zbar)+rho*log(z(-1))+ez;
end;


initval;
theta 	=	 0.983917;
u     	=	 0.0690197;
v     	=	 0.0679096;
q     	=	 1.37091;
f     	=	 1.34886;
W     	=	 94.2941;
U     	=	 93.8905;
J     	=	 0.156941;
w     	=	 0.982893;
z     	=	 1;
end;


steady;
check;
model_diagnostics; 
model_info;

shocks;
var ez = 0.01^2;
end;


stoch_simul(order=1, irf=41) z u v w f q theta;
