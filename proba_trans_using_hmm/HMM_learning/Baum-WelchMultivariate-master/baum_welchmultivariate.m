function [piefin,B_fin,A_fin, pprob]=baum_welchmultivariate


%%
%% Author : Suryansh Kumar
%% Supervised by: Dr. Dizan Vasquez (e-Motion Group, INRIA-Rhone Alpes Grenoble) 
%%


%%B Gaussian for each state
%%A transition matrix of N x N
%%N number of states
%%T size of sequence of observations



%%%%%%%%%%%%%%%%%%%%%%%%%%% Intialization of Variables%%%%%%%%%%%%%%%


pie =[ 0.33    0.33    0.33]; %intial probability
A = [0.33 0.33 0.33;0.33 0.33 0.33;0.33 0.33 ,0.33];% Initial Transition Matrix
N = 3;                                                                  % Number of State
K = 3;                                                                  % in my case i put it 3, it will vary depending on how you are taking your observation sequence
dimension = 2;                                                          % dimension of the data, in my case i am taking two dimensional observation sequence

                                                                           % Mean of the different State
mu_s = [mu_s1, mu_s2];  
mu_l = [mu_l1, mu_l2];
mu_r = [mu_r1, mu_r2];

                                                
                                                                            %Covariance of the different state                
sigma_s = [s11, s12; 
                s21, s22];
sigma_l = [l11, l12; 
                l21, l22];
sigma_r = [r11, r12;
                r21, r22];
            
            

            
                                                                            % Defining a B structure to store mean and covariance
field = 'pdf';
value = cell(3,2);
value(1,1) = {mu_s};
value(2,1) = {mu_l};
value(3,1) = {mu_r};
value(1,2) = {sigma_s};
value(2,2) = {sigma_l};
value(3,2) = {sigma_r};
B = struct(field,value);




                                                                            % Defining a B_fin structure to give fina mean and final covariance

field = 'pdf';
value = cell(3,2);
value(1,1) = {mu_s};
value(2,1) = {mu_l};
value(3,1) = {mu_r};
value(1,2) = {sigma_s};
value(2,2) = {sigma_l};
value(3,2) = {sigma_r};
B_fin = struct(field,value);



                                                                            %Observation data stucture
[D1 D2 D3] = Data;
field_obs = 'obs';
value_obs = cell(1,3);
value_obs(1,1) = {D1};
value_obs(1,2) = {D2};
value_obs(1,3) = {D3};
O = struct(field_obs,value_obs);




                                                                            % structure 'a' is for storing alpha from the forward algorithm

[m n] = size(O(1).obs);

field_alpha = 'alpha';
value_alpha = cell(1,3);

value_alpha(1,1) = {zeros(N, m)};
value_alpha(1,2) = {zeros(N, m)};
value_alpha(1,3) = {zeros(N, m)};
a = struct(field_alpha, value_alpha);

                                                                            % structure 'bb' is for storing beta from the backward algorithm

field_beta = 'beta';
value_beta = cell(1,3);
value_beta(1,1) = {zeros(N, m)};
value_beta(1,2) = {zeros(N, m)};
value_beta(1,3) = {zeros(N, m)};
bb = struct(field_beta, value_beta);



                                                                            % structure 'scale' is for storing normalising constants.
field_c = 'c';
value_c = cell(1,3);
value_c(1,1) = {zeros(m,1)};
value_c(1,2) = {zeros(m,1)};
value_c(1,3) = {zeros(m,1)};
scale = struct(field_c, value_c);



no_of_iteration = 3;





%%%%%%%%%%%%%%%%%%%%%%%%%%%Intialization Done %%%%%%%%%%%%%%%%%%%%%%%


pprob=0.0;
A_fin=zeros(N,N);

it=0;
converged = 0;

while (~converged)

    pprob=0.0;
    it = it + 1;
    lgPO=zeros(K,1);    
 
        for k=1:K
      [T temp]=size(O(k).obs);
      [a(k).alfa, scale(k).c]=Forward_multivariate(O(k).obs,pie, B, A, N, T);
      bb(k).beta=Backward_multivariate(O(k).obs,pie, B, A, N, T,scale(k).c);
        for index=1:T
            lgPO(k)= lgPO(k) + log(scale(k).c(index)); 
            lgc(index)=log(scale(k).c(index));
        end

        end


    for k=1:K
	pprob = pprob - lgPO(k); 
    end
    %pprob 
    den=0.0;
    num=0.0;
    num_mu = cell(1,N);
    num_sigma = cell(1,N);
    
   
    sum=0.0;
    
    
    
    for i=1:N
     
        for k=1:K
            sum= sum + a(k).alfa(i,1)*(1/scale(k).c(1,1))*bb(k).beta(i,1);
        end
        piefin(i)= sum/K;
        
        
        sum=0.0;
        
    
    for k=1:K
        [T temp]=size(O(k).obs);

            
            mu_numerator = zeros(1,dimension);
            sigma_numerator = zeros(dimension,dimension);
            mu_denominator = 0.0;
            for t = 1:T
                mu_numerator = mu_numerator + (1/scale(k).c(t,1))*a(k).alfa(i,t)*bb(k).beta(i,t)*O(k).obs(t,:);
                tempvar =  ((O(k).obs(t,:)-B(i,1).pdf)')*(O(k).obs(t,:)-B(i,1).pdf);
                sigma_numerator = sigma_numerator + (1/scale(k).c(t,1))*a(k).alfa(i,t)*bb(k).beta(i,t)*tempvar;
                mu_denominator = mu_denominator + (1/scale(k).c(t,1))*a(k).alfa(i,t)*bb(k).beta(i,t);
            end
      
            
            
            num_mu(1,i)={mu_numerator/mu_denominator };
            num_sigma(1,i) = { sigma_numerator/ mu_denominator };
           

    end
            
   
  

	B_fin(i,1).pdf=num_mu(1,i);
    B_fin(i,2).pdf=num_sigma(1,i);
    B_fin(i,1).pdf= cell2mat(B_fin(i,1).pdf);
    B_fin(i,2).pdf= cell2mat(B_fin(i,2).pdf);
    

	den=0.0;
	num_mu = cell(1,N);


    
        for j=1:N
            for k=1:K
	        [T temp]=size(O(k).obs);
		sum1=0.0;
		sum2=0.0;
                for t=2:T
                 sum1 =  sum1+ a(k).alfa(i,t-1)*A(i,j)*gaussian_multivariate(O(k).obs(t,:), B(j,1).pdf, B(j,2).pdf)*bb(k).beta(j,t);
                 sum2 =  sum2 + a(k).alfa(i,t-1)*bb(k).beta(i,t-1)/scale(k).c(t-1,1);
                end
		num =  num + sum1;
		den =  den + sum2;
            end
	    A_fin(i,j)=num/den;
	    den=0.0;
	    num=0.0;
        end
    end



    if(it==no_of_iteration)
	converged = 1;
    
    else
	pprob_old = pprob;

	pie = piefin;
	B = B_fin;
    A = A_fin;
    end

    end
    

end
