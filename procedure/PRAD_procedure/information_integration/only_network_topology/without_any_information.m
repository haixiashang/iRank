clear;clc;close all;
%% gene level ����Ϣ
% ����RegNetwork ��Ϣ
% % without any information, just regnetwork  gene regulation part
G_data=importdata('Reg_intersect.txt');
used_G=G_data.data;
Sg=unique(used_G(:,1));
Tg=unique(used_G(:,2));
Go_node=unique(union(Sg,Tg));
%% Reg level Transition Matrix Construction
Reg_node=unique(Go_node);
NR=length(Reg_node);
R=sparse(NR,NR);
RCS=sparse(NR,NR);
% ����gene regulation 
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
% ת�ƾ������滯
sum_R=sum(R,1);
for(i=1:length(sum_R))
    if(sum_R(i)>0)
    R(:,i)= R(:,i)/sum_R(i);
    end
end
RTW=R;
%% ���������ת�ƾ���
Node_all=[Reg_node];
number=length(Node_all);
Trans=sparse(number,number);
Trans(1:NR,1:NR)=RTW;

CS=sparse(number,number);
CS(1:NR,1:NR)=RCS;
%%  �������
r=0.85;
threshold=1e-10;%
N = length(Trans);
PR =( 1/N*ones(N,1));%
restart =PR;
iter = 1;
delta_PR = Inf; 
while (delta_PR > threshold || iter>200)    %iterate until error is less than 1e-10 1e-7
    tic;
    prev_PR = PR;               %save previous PageRank vector (t-1)
    CST=CS.*(1*Trans);%*1/N Trns'
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
length(unique(LRPR))
HD =importdata('29.txt');
D=[]; ii=1;
for(i=1:length(HD))
  l1=find((HD(i)+0.3)==Reg_node);
    if(~isempty(l1))
              D(ii,1)=HD(i);
              D(ii,2)=PR(l1);
              D(ii,3)=find(PR(l1)==LRPR);
              ii=ii+1;
    end
end
Normal_rank=[];Normal_pr=[];Normal_id=[];
%% �洢����ָ��
Auc=[];
Circle=1000;
normal_genes_all=(Reg_node);
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
% �洢һ��rank
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
score=[D(:,2)',nor(:,2)'];
[Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(y_p,score,'true');

Auc(count)=AUCsvm;
end
boxplot(Auc)
max(Auc),mean(Auc),min(Auc),median(Auc)
save('ORI_disease_29.mat','D','Auc','Normal_id','Normal_pr','Normal_rank','-v6')
mean(F1_score1)
mean(Acc1)
mean(Sp1)
mean(Se1)




