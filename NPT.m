function [Phi,Phi_t] = NPT(M_train,M_test,kappa)
% This fucntion implements NON-Linear Projection Trick (NPT)
% Input:  M_train = Train data
%         M_test = Test data
%         kappa = Hyperparameter which determines the width of the kernel
% Output: Phi = Output Phi train
%         Phi_t = Output Phi test
%RBF kernel
N = size(M_train,2);  NN = size(M_test,2);
Dtrain = ((sum(M_train'.^2,2)*ones(1,N))+(sum(M_train'.^2,2)*ones(1,N))'-(2*(M_train'*M_train)));
Dtest = ((sum(M_train'.^2,2)*ones(1,NN))+(sum(M_test'.^2,2)*ones(1,N))'-(2*(M_train'*M_test)));
sigma2 = kappa * mean(mean(Dtrain));  A = 2.0 * sigma2;
Ktrain = exp(-Dtrain/A);  		      Ktest = exp(-Dtest/A);
%center_kernel_matrices
N = size(Ktrain,2);  M = size(Ktest,2);
Ktest = (eye(N,N)-ones(N,N)/N) * (Ktest - (Ktrain*ones(N,1)/N)*ones(1,M));
Ktrain = (eye(N,N)-ones(N,N)/N) * Ktrain * (eye(N,N)-ones(N,N)/N);
[U,S] = eig(Ktrain);        s = diag(S);
s(s<10^-6) = 0.0;
[U, s] = sortEigVecs(U,s);  s_acc = cumsum(s)/sum(s);   S = diag(s);
II = find(s_acc>=0.999);
LL = II(1);
Pmat = pinv(( S(1:LL,1:LL)^(0.5) * U(:,1:LL)' )');
Phi = Pmat*Ktrain;                      Phi_t = pinv(Phi')*Ktest;
end
