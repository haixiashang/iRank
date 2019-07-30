clear;clc;close all;
%% gene level ����Ϣ
% ����RegNetwork ��Ϣ
G_data=importdata('Reg_intersect.txt');
used_G=G_data.data(:,:);
Sg=unique(used_G(:,1));
Tg=unique(used_G(:,2));
Go_node=unique(union(Sg,Tg));
% ����miRNA ��Ϣ
M_data=importdata('miRNA_intersect.txt');
used_M=M_data.data(:,:);
Sm=unique(used_M(:,1));
Tm=unique(used_M(:,2));
Mo_node=unique(union(Sm,Tm));
%% Reg level Transition Matrix Construction
Reg_node=unique(union(Go_node,Mo_node));
NR=length(Reg_node);
R=sparse(NR,NR);
RW=sparse(NR,NR);
RCS=sparse(NR,NR);
% ����gene regulation ��Ϣ
for(i=1:length(used_G))
    l1=find(used_G(i,1)==Reg_node);
    l2=find(used_G(i,2)==Reg_node);
    if(~isempty(l1))
        if(~isempty(l2))
            R(l2,l1)=1;
            RW(l2,l1)=used_G(i,3);
            RCS(l2,l1)=1;
        end
    end
end
% ����miRNA regulation ��Ϣ
for(i=1:length(used_M))
    l1=find(used_M(i,1)==Reg_node);
    l2=find(used_M(i,2)==Reg_node);
    if(~isempty(l1))
        if(~isempty(l2))
            R(l2,l1)=1;
            RW(l2,l1)=used_M(i,3);
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
% ת�ƾ����Ȩ
RTW=R.*RW;
%%  ����DNA methylation ��Ϣ
D_data=importdata('DNA_intersect.txt');
used_D=D_data.data(:,:);
% ����DNA--->RegNetwork��ת�ƾ���
lamda=0.1;
D_num=(intersect(unique(used_D(:,2)-0.3),(Reg_node-0.3)))+0.2;
DR=sparse(NR,length(D_num));
DWR=sparse(NR,length(D_num));
DRCS=sparse(NR,length(D_num));
for(i=1:length(used_D))
    l1=find((used_D(i,1))==D_num);
    l2=find(used_D(i,2)==Reg_node);
    if(~isempty(l1))
        if(~isempty(l2))
           DR(l2,l1)=1;
           DWR(l2,l1)=used_D(i,3);
           DRCS(l2,l1)=1;
        end
    end
end
% ת�ƾ������滯
sum_D=sum(DR,1);
for(i=1:length(sum_D))
    if(sum_D(i)>0)
        DR(:,i)=DR(:,i)/sum_D(i);
    end
end
% ת�ƾ�������Ȩ��
DRTW=DR.*DWR*(lamda/2);
%% ����CNV ��Ϣ
C_data=importdata('CNV_intersect.txt');
used_C=C_data.data(:,:);
% ����CNV---->Regnetwork��ת�ƾ���
C_num=intersect(unique(used_C(:,2)-0.3),(Reg_node-0.3))+0.1;
CR=sparse(NR,length(C_num));
CWR=sparse(NR,length(C_num));
CRCS=sparse(NR,length(C_num));
for(i=1:length(used_C))
    l1=find((used_C(i,1))==C_num);
    l2=find(used_C(i,2)==Reg_node);
    if(~isempty(l1))
        if(~isempty(l2))
           CR(l2,l1)=1;
           CWR(l2,l1)=used_C(i,3);
           CRCS(l2,l1)=1;
        end
    end
end
% ת�ƾ������滯
sum_C=sum(CR,1);
for(i=1:length(sum_C))
    if(sum_C(i)>0)
        CR(:,i)=CR(:,i)/sum_C(i);
    end
end
% ת�ƾ�������Ȩ��
CRTW=CR.*CWR*(lamda/2);
%% ���������ת�ƾ���
Node_all=[Reg_node;D_num;C_num];
number=length(Node_all);
Trans=sparse(number,number);
Trans(1:NR,1:NR)=RTW;
Trans((1:NR),(NR+1):(NR+length(D_num)))=DRTW;
Trans((1:NR),((NR+length(D_num))+1):(((NR+length(D_num)))+length(C_num)))=CRTW;

CS=sparse(number,number);
CS(1:NR,1:NR)=RCS;
CS((1:NR),(NR+1):(NR+length(D_num)))=DRCS;
CS((1:NR),((NR+length(D_num))+1):((NR+length(D_num))+length(C_num)))=CRCS;
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
%% gene ������ 1�е��������� RegNetwork �е�����
[LRPR,LRrank]=sort(unique(PR(1:NR)),'descend');
length(unique(LRPR))
%% gene ������2�е���������  DNA methylation�е�����
[LDPR,LDrank]=sort(unique(PR((NR+1):(NR+length(D_num)))),'descend');
length(unique(LDPR))
%% gene������4�е��������� CNV�е�����
[LCPR,LCrank]=sort(unique(PR(((NR+length(D_num))+1):end)),'descend');
length(unique(LCPR))
%% ��ȡdisease genes
HD = importdata('29.txt');
D=[]; ii=1;
for(i=1:length(HD))
    l1=find((HD(i)+0.3)==Reg_node);
    l11=find((HD(i)+0.3)==unique(used_M(:,2)));
    l2=find((HD(i)+0.2)==D_num);
    l4=find((HD(i)+0.1)==C_num);
    if(~isempty(l1))
        if(~isempty(l11))
            if(~isempty(l2))
                    if(~isempty(l4))
                        D(ii,1)=HD(i);
                        D(ii,2)=PR(l1);
                        D(ii,3)=find(PR(l1)==LRPR);
                        ii=ii+1;
                    end
            end
        end
    end
end
Auc=[];
Normal_rank=[];
Normal_pr=[];
Normal_id=[];
Circle=1000;
M_num=unique(used_M(:,2));
normal_genes_all=intersect((D_num-0.2),intersect((C_num-0.1),(M_num-0.3)));
Candidate_normal=setdiff(normal_genes_all,D(:,1));

for(count=1:Circle)
Rand_loc_p=randperm(length(Candidate_normal),length(D));
Rand_gene_ID=Candidate_normal(Rand_loc_p);
nor=[];ii=1;
for(i=1:length(Rand_loc_p))
    l1=find((Rand_gene_ID(i)+0.3)==Reg_node);
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
y_p=(1:(2*(length(D_rank_f))))'<(length(D_rank_f));
score=[D(:,2)',nor(:,2)'];
[Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(y_p,score,'true');

Auc(count)=AUCsvm;
end
% boxplot(Auc)
% max(Auc)
mean(Auc)
% min(Auc)
% std(Auc)
% median(Auc)
save('RMDC_29.mat','D','Auc','Normal_id','Normal_pr','Normal_rank','-v6')

