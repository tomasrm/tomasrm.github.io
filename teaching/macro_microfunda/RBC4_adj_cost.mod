// RBC Model 4 - Investment adjustment cost
// This file was modified by Tomás Martinez for teaching purposes.
// Original file comes from José L. Torres (U Malága). 
// I cannot guarantee that it is error-free.


// Endogenous variables of the model
var Y, C, I, K, L, W, R, q, A;

// Exogenous shock
varexo ea ;

// Parameters of the model
parameters alpha, beta, delta, gamma, psi, rho;

// Calibration of parameters
alpha = 0.35;
beta = 0.97;
delta = 0.06;
gamma = 0.40;
psi = 6.00;  // adjustment cost parameter
rho = 0.95;

// Model equations:
model;
C=(gamma/(1-gamma))*(1-L)*W;
q=beta*(C/C(+1))*(q(+1)*(1-delta)+R(+1));

q-q*psi/2*((I/I(-1))-1)^2-q*psi*((I/I(-1))-1)
*I/I(-1)+beta*C/C(+1)*q(+1)*psi*((I(+1)/I)-1)
*(I(+1)/I)^2=1;  // investiment equation

Y = A*(K(-1)^alpha)*(L^(1-alpha));
K = (1-delta)*K(-1)+(1-(psi/2*(I/I(-1)-1)^2))*I;
I = Y-C;
W = (1-alpha)*A*(K(-1)^alpha)*(L^(-alpha));
R = alpha*A*(K(-1)^(alpha-1))*(L^(1-alpha));
log(A) = rho*log(A(-1))+ ea;
end;

// Initial values
initval;
Y = 1;
C = 0.8;
L = 0.3;
K = 3.5;
I = 0.2;
q = 1;
W = (1-alpha)*Y/L;
R = alpha*Y/K;
A = 1;
ea = 0;
end;


steady;
check;
model_diagnostics; 
model_info;

shocks;
var ea;
stderr 0.01; // 1% shock
end;

stoch_simul(order=1, irf=200);
