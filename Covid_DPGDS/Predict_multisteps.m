            
function [XP_temp,abser,Rec_data] = Predict_multisteps(Para_sample,Theta_sample,T,T_test,V,L,pred_count,delta,X_W_avg,task)


XP_temp    =   zeros(V,pred_count,T_test,size(Para_sample,2));
Rec_data   =   zeros(V,   T,   size(Para_sample,2));
abser     =   zeros(V,T_test,size(Para_sample,2));
Theta_pred = cell(L,1);           
Theta_last = cell(L,1);  

    for num_sample = 1:size(Para_sample,2)
        
        Theta_tmp = Theta_sample{1,num_sample};
        Phi_tmp   = Para_sample{1,num_sample}.Phi;
        Pi_tmp    = Para_sample{1,num_sample}.Pi;
        delta_tmp = delta{1,num_sample};
  
        Lambda   =  bsxfun(@times,delta_tmp{1}(end)', Phi_tmp{1}* Theta_tmp{1});
        Rec_data(:,:,num_sample) = poissrnd(Lambda);  
            
        for cc = 1: pred_count  
                for tstep =1:T_test
                        % obtain the latent state at last time step for the observed data
                         for l=1:L
                             
                            if tstep == 1
                               Theta_last{l} = Theta_tmp{l}(:,end);
                            else
                               Theta_last{l} = Theta_pred{l};
                            end
                            
                         end

                    for l = L:-1:1
                        if l==L
                            Theta_pred{l} = randg(Pi_tmp{l}*Theta_last{l});
                        else
                            Theta_pred{l} = randg(Phi_tmp{l+1}*Theta_pred{l+1}+Pi_tmp{l}*Theta_last{l});
                        end
                    end
                    
                    XP_temp(:,cc,tstep,num_sample) = poissrnd(bsxfun(@times,delta_tmp{1}(end)', Phi_tmp{1} * Theta_pred{1}));%����

                end


        end 
  
        
        
            XP_avg_temp = squeeze(mean(XP_temp,2));
            
            if strcmp(task,'prediction_historic')
                
                for tstep =1:T_test
                    abser(:,tstep,num_sample) = mean(abs(XP_avg_temp(:,tstep,num_sample)- X_W_avg(:,tstep))./(X_W_avg(:,tstep)+1),2);
                end
            else
                
                abser=[];
            end        
 
     
            
    end


    
        
end
