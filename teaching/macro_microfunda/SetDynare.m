%%% Set a basic model in Dynare by Tomás Martínez
%% First: Download and Install Dynare in your computer.
% Check where the Dynare is located in your computer!
% Windows likely is here: C:\dynare\6.0 probably 
% Mac likely is here:  /Applications/Dynare

%% Second: Set dynare and your current directory
% Set your dynare (look at the version you have installed!)
% If you have installed Dynare in a non-standard directory, adjust the path accordingly.
% This depends on the dynare version, computer used, where the dynare is
% located, etc. 
% Write the commands in the MatLab Command Window:
addpath /Applications/Dynare/6.0-x86_64/matlab % Mac
addpath c:\dynare\6.0\matlab  % Windows

% Set the working directory where the mod files are located
cd('C:\Users\tomasrm1\Teaching\Insper\Macro_microfund\code')
cd('/Users/tomasrm/Teaching/Insper/Macro_microfund/code') 

%% Third: Build you mod file based on your model and the calibration (or
% estimation) of the parameters.

% Remember: Remember that each instruction (or line) of the .mod file must
% be terminated by a semi-colon (;). 

% "var" starts the list of endogenous variables, to be separated by commas.

% "varexo" list the exogenous variables that will receive the shock.

% "parameters" starts the list of parameters and assigns values to each.

% "model" set the equations that will define your model. In the RBC, that
% will be the FOC, the feasibility and LOM. In other models you might want
% to include value functions. Feel free to experiment as long the number of
% (relevant) equations should be equal to the number of endogenous
% variables. NOTE: In Dynare, the timing of each variable reflects when 
% that variable is decided. For instance, our capital stock is not decided 
% today, but yesterday thus you write k(-1). You do not need to write
% expectations, dynare understand that in a stochastic evironment c(1) are
% expected next period variables. After you finish your model, you should
% write "end;".
% An useful trick is to write the endogenous variables with exponential:
% exp(c). In this case, the impulse response functions will be in %
% deviations. Very useful to interpret the model. 

% "initval;" this is your initial guess of the steady state. If you 
% do not write "steady;" it will also be the starting point of your IRF. 

% "shocks;" here you specify the variance of your exogenous variables. If
% you have multiple shocks you can also specify the correlation between
% shocks.

% This is the basic of a stochastic model in dynare. You can add diferent
% features: "endval;" if you want to calculate a transition path to a
% different steady state. Temporary shocks (you have to specify the
% duration and the value of the shock), or permanent (antecipated or not)
% shocks.


%% Fourth: Solve your model! 
dynare RBC1.mod 

% Looking at the output we have:

% Steady state results: In this model we log linearized before hand,
% therefore our SS are zero for all the variables! This does not need to be
% the case! The command "steady;" calculate the steady state. You can
% specify the algorithm you use to solve the SS.

% Eigenvalues: We can summarize the model in a system of forward looking
% difference equations. However, to have a unique solution the system
% requires that the number of predetermined variables (kt and theta) to be
% equal to the number of stable eigenvalues (or the number of jump
% variables (forward looking) = to the number of unstable eigenvalues).
% This is the Blanchard-Kahn condition. Dynare check it with the command 
% "check;".

% The rest of the output is resulted from the command "stoch_simul(...);",
% and mostly depends on the specified options.
% Model summary gives the number of each variable type in your model. 
% The matrix of covariance of exogenous shock is the one you specified in
% your .mod file. 
% Policy and trasition functions are your policy functions and it depends
% on your state variables (state space notation). Use the option 
% "nofunctions" to suppress the policy function.
% Theoretical moments: Asymptotics moments of the endogenous variables.  
% Matrix of correlations: the correlation coefficient of the variables.
% Autocorrelation: Autocorrelation of the var. up to order 5.
% Use the option "nomoments" or "nocorr" to suppress all the moments (or 
% just the correlations).
% The graph of the impulse response functions appear with the option "irf=#
% periods". 
% The option "order=1" is the order of approximation of the linearization.
% 90% of the time you will use 1, the other 9.9999% of the time you use 2. It is
% very unlikely that you will ever go above this.
% If you do not need the info of all the variables: "stoch_simul(...) y
% c;".

% Other useful options: noprint (useful for loops), periods=# (it will
% calculate the moments of the simulated data), simul_seed=# (set the seed
% for simulations). And much more! Check the user guide.

% In your workspace you can get all the output that dynare generated: the
% parameters alpha, beta... the values calculated for the IRF c_ea,
% y_ea (variable_shock)... oo_ is where you can find most of the stuff,
% oo_.dr has the parameters of the policy functions (ghx ghu), the
% eigenvalues (eigval), the steady state values (ys), and other stuff if
% you specified a different option. You can get the summary statistics in
% oo_.mean, oo_.var, oo_.autocorr (oo_.gamma_y also store all the 
% theoretical moments) and etc. If you want to perform your own
% simulations or create your table is always useful to have these values.

ss=oo_.dr.ys;
display(ss) 

% Other useful tips: 
dynare RBC2.mod  

% You do not need to manually log-linearize your model to get the variables
% in log. To write your model in logs: let ã=ln(a), then exp(ã)=a. So you
% rewrite all the variables you want to be in log as exp(.). 

% If you want to simulate the models for just one different parameter, you
% just need to modify this parameter and run the stoch_simul(...) again 
% (see the code of RBC2). You can actually run loops with that and specify
% some stop conditions until you achieve the moments you want given the
% calibration of the parameter. 

% You can include matlab program/functions inside your mod files. E.g. a
% program that calculate the SS analytically. You could use such a program to
% give the initval equal to the SS you get from your program. 

% You could use the policy functions to do your own simulations with
% generated shocks. 

% If you want to compare two models, you can always write how many models
% you want inside the mod file. However, you would have to specify
% different names for the endogenous variables and shocks (you could still
% use the same parameters).

% Dynare "clear all" everytime you run a mod file, thereby deleting all
% your workspace. You can specify "dynare blabla.mod noclearall" in case
% you don't want to do that.


