clear;clc;close all;
%% gene level ����Ϣ
% % without any information, just regnetwork  gene regulation part
G_data=importdata('Regnetwork_only_gene.txt');
Source=[];
for(i=1:length(G_data.textdata(2:end,2)))
    l1=G_data.textdata(1+i,2);
    Source(i,1)=str2num(char(l1));
end
Target=G_data.data;
used_G=[Source,Target];
Sg=unique(used_G(:,1));
Tg=unique(used_G(:,2));
Go_node=unique(union(Sg,Tg));

%% Reg level Transition Matrix Construction
Reg_node=unique(Go_node);
NR=length(Reg_node);
R=sparse(NR,NR);
RCS=sparse(NR,NR);
% add gene regulation  information 
for(i=1:length(used_G))
    l1=find(used_G(i,1)==Reg_node);
    l2=find(used_G(i,2)==Reg_node);
    if(~isempty(l1))
        if(~isempty(l2))
            R(l2,l1)=1;
            RCS(l2,l1)=1;
        end
    end
end

% normalize transition matrix
sum_R=sum(R,1);
for(i=1:length(sum_R))
    if(sum_R(i)>0)
    R(:,i)= R(:,i)/sum_R(i);
    end
end
RTW=R;
%%  Input to CPR
% Node_all=[Reg_node;D_num;S_num;C_num];
Node_all=[Reg_node];
number=length(Node_all);
Trans=sparse(number,number);
Trans(1:NR,1:NR)=RTW;

CS=sparse(number,number);
CS(1:NR,1:NR)=RCS;

%%  �������
% restart parameter
r=0.85;
% threshold 
threshold=1e-10;
N = length(Trans);
% seeds
PR =( 1/N*ones(N,1));
restart =PR;
iter = 1;
delta_PR = Inf; 
while (delta_PR > threshold || iter>200)    
    tic;
    prev_PR = PR;               
    CST=CS.*(1*Trans);
    CST(find(isnan(CST)==1))=0;
    PR = r*CST* PR + (1-r)*restart;     %calculate new Pa
    delta_PR= norm(PR-prev_PR);%calculate new error
    t(iter)=toc;
    iter = iter + 1;
end
length(unique(PR))
[Rank,index]=sort(unique(PR'),'descend');%
rank=1:length(unique(PR));
%% gene rank in RegNetwork 
[LRPR,LRrank]=sort(unique(PR(1:NR)),'descend');

%% read disease genes
% gain information of disease genes
disease = importdata('hcc_disease_genes.txt');
HD = disease.data;
D=[]; ii=1;
for(i=1:length(HD))
     l1=find((HD(i))==Reg_node);
             if(~isempty(l1))
                 D(ii,1)=HD(i);
                 D(ii,2)=PR(l1);
                 D(ii,3)=find(PR(l1)==LRPR);
                  ii=ii+1;
             end
end
% select and store normal genes
Normal_rank=[];Normal_pr=[];Normal_id=[];
%% �洢����ָ��
Auc=[];
%%  repeat 1000 times
Circle=1000;
normal_genes_all=(Reg_node);
% candidate normal genes
Candidate_normal=setdiff(normal_genes_all,D(:,1));
for(count=1:Circle)
Rand_loc_p=randperm(length(Candidate_normal),length(D));
Rand_gene_ID=Candidate_normal(Rand_loc_p);
nor=[];ii=1;
for(i=1:length(Rand_loc_p))
    l1=find(Rand_gene_ID(i)==Reg_node);
    if(~isempty(l1))
        nor(ii,1)=Rand_gene_ID(i);
        nor(ii,2)=PR(l1);
        nor(ii,3)=find(PR(l1)==LRPR);
        ii=ii+1;
    end
end
% store normal genes information
for(j=1:length(nor))
Normal_rank(j,count)=nor(j,3);
Normal_pr(j,count)=nor(j,2);
Normal_id(j,count)=nor(j,1);
end
nor_rank_f=nor(:,3);
D_rank_f=D(:,3);

data_p=[];
for(i=1:(2*(length(D_rank_f))))
    if(i<=length(D_rank_f))
   data_p(i,1) =D_rank_f(i);%disease 
    else
       data_p(i,1) = nor_rank_f(i-length(D_rank_f)); % normal 
    end
end
y_p=(1:(2*(length(D_rank_f))))'<(length(D_rank_f));%>

%with label normal----0  tumor----1
mdlSVM = fitcsvm(data_p,y_p,'Standardize',true);
mdlSVM = fitPosterior(mdlSVM);
[Lable,score_svm] = resubPredict(mdlSVM);%

[Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(y_p,score_svm(:,mdlSVM.ClassNames),'true');
Auc(count)=AUCsvm;
end
boxplot(Auc)
max(Auc),mean(Auc),min(Auc),median(Auc)
% store results
save('ORI_disease_33_new.mat','D','Auc','Normal_id','Normal_pr','Normal_rank','-v6')
% mean(F1_score1)
% mean(Acc1)
% mean(Sp1)
% mean(Se1)
% length(find(Auc>0.7)),length(find(Auc<0.6))
% std(Auc)



