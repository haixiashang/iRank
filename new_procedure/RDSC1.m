clear;clc;close all;
%% gene level 的信息
% 加载RegNetwork 信息
G_data=importdata('data_used_rna_10_22.txt');
used_G=G_data.data(:,[1,2,4]);
used_G=used_G(find(used_G(:,3)>0),:);
Sg=unique(used_G(:,1));
Tg=unique(used_G(:,2));
Go_node=unique(union(Sg,Tg));
% 加载miRNA 信息
% M_data=importdata('TarBase_with_miRNA_new.txt');
% used_M=M_data.data(:,[1,2,4]);
% used_M=used_M(find(used_M(:,3)>0),:);
% Sm=unique(used_M(:,1));
% Tm=unique(used_M(:,2));
% Mo_node=unique(union(Sm,Tm));
%% Reg level Transition Matrix Construction
% Reg_node=unique(union(Go_node,Mo_node));
Reg_node=unique(Go_node);
NR=length(Reg_node);
R=sparse(NR,NR);
RW=sparse(NR,NR);
RCS=sparse(NR,NR);
% 加入gene regulation 信息
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
length(find(RW>0))
% % 加入miRNA regulation 信息
% for(i=1:length(used_M))
%     l1=find(used_M(i,1)==Reg_node);
%     l2=find(used_M(i,2)==Reg_node);
%     if(~isempty(l1))
%         if(~isempty(l2))
%             R(l2,l1)=1;
%             RW(l2,l1)=used_M(i,3);
%             RCS(l2,l1)=1;
%         end
%     end
% end
% 转移矩阵正规化
sum_R=sum(R,1);
for(i=1:length(sum_R))
    if(sum_R(i)>0)
    R(:,i)= R(:,i)/sum_R(i);
    end
end
% 转移矩阵加权
RTW=R.*RW;
%%  加载DNA methylation 信息
D_data=importdata('data_used_DNA_methylation_10_22.txt');
used_D=D_data.data(:,[1,2,4]);
used_D=used_D(find(used_D(:,3)>0),:);
% 创建DNA--->RegNetwork的转移矩阵
lamda=0.1;
D_num=(intersect(unique(used_D(:,2)-0.4),(Reg_node-0.4)))+0.2;
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
length(find(DR==1))
% 转移矩阵正规化
sum_D=sum(DR,1);
for(i=1:length(sum_D))
    if(sum_D(i)>0)
        DR(:,i)=DR(:,i)/sum_D(i);
    end
end
% 转移矩阵增加权重
DRTW=DR.*DWR*(lamda/2);
%% 加载somatic信息
S_data=importdata('data_used_somatic_10_22.txt');
used_S=S_data.data(:,[1,2,4]);
used_S=used_S(find(used_S(:,3)>0),:);
% 创建Somatic --->RegNetwork的转移矩阵
S_num=intersect(unique(used_S(:,2)-0.4),(Reg_node-0.4))+0.3;
SR=sparse(NR,length(S_num));
SWR=sparse(NR,length(S_num));
SRCS=sparse(NR,length(S_num));
for(i=1:length(used_S))
    l1=find((used_S(i,1))==S_num);
    l2=find(used_S(i,2)==Reg_node);
    if(~isempty(l1))
        if(~isempty(l2))
           SR(l2,l1)=1;
           SWR(l2,l1)=used_S(i,3);
           SRCS(l2,l1)=1;
        end
    end
end
length(find(SR==1))
% 转移矩阵正规化
sum_S=sum(SR,1);
for(i=1:length(sum_S))
    if(sum_S(i)>0)
        SR(:,i)=SR(:,i)/sum_S(i);
    end
end
% 转移矩阵增加权重
SRTW=SR.*SWR*(lamda/2);
%% 加载CNV 信息
C_data=importdata('data_used_cnv_10_22.txt');
used_C=C_data.data(:,[1,2,4]);
used_C=used_C(find(used_C(:,3)>0),:);
% 创建CNV---->Regnetwork的转移矩阵
C_num=intersect(unique(used_C(:,2)-0.4),(Reg_node-0.4))+0.1;
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
length(find(CR==1))
% 转移矩阵正规化
sum_C=sum(CR,1);
for(i=1:length(sum_C))
    if(sum_C(i)>0)
        CR(:,i)=CR(:,i)/sum_C(i);
    end
end
% 转移矩阵增加权重
CRTW=CR.*CWR*(lamda/2);
%% 构建总体的转移矩阵
Node_all=[Reg_node;D_num;S_num;C_num];
number=length(Node_all);
Trans=sparse(number,number);
Trans(1:NR,1:NR)=RTW;
Trans((1:NR),(NR+1):(NR+length(D_num)))=DRTW;
Trans((1:NR),(NR+length(D_num)+1):((NR+length(D_num))+length(S_num)))=SRTW;
Trans((1:NR),((NR+length(D_num))+length(S_num)+1):(((NR+length(D_num))+length(S_num))+length(C_num)))=CRTW;

CS=sparse(number,number);
CS(1:NR,1:NR)=RCS;
CS((1:NR),(NR+1):(NR+length(D_num)))=DRCS;
CS((1:NR),(NR+length(D_num)+1):((NR+length(D_num))+length(S_num)))=SRCS;
CS((1:NR),((NR+length(D_num))+length(S_num)+1):(((NR+length(D_num))+length(S_num))+length(C_num)))=CRCS;
%%  输入程序
r=0.85;
threshold=1e-10;%阈值的筛选基于节点的最小值
N = length(Trans);
PR =( 1/N*ones(N,1));%首先使用均匀分布%之后使用疾病位点作为种子
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
%% gene 在网络 1中单独的排序 RegNetwork 中的排序
[LRPR,LRrank]=sort(unique(PR(1:NR)),'descend');
length(unique(LRPR))
%% gene 在网络2中单独的排序  DNA methylation中的排序
[LDPR,LDrank]=sort(unique(PR((NR+1):(NR+length(D_num)))),'descend');
length(unique(LDPR))
%% gene在网络3中单独的排序 Somatic中的排序
[LSPR,LSrank]=sort(unique(PR((NR+length(D_num)+1):((NR+length(D_num))+length(S_num)))),'descend');
length(unique(LSPR))
%% gene在网络4中单独的排序 CNV中的排序
[LCPR,LCrank]=sort(unique(PR(((NR+length(D_num))+length(S_num)+1):end)),'descend');
length(unique(LCPR))
%% 读取disease genes
% 获取disease genes在reg中的排序
% HDin=xlsread('HCC_in_miRNA_relation.csv');
% HD=HDin(find(HDin(:,2)>0.2),1);
HD=xlsread('33_disease.csv');
D=[]; ii=1;
for(i=1:length(HD))
    l1=find((HD(i)+0.4)==Reg_node);
%     l11=find((HD(i)+0.4)==unique(used_M(:,2)));
    l2=find((HD(i)+0.2)==D_num);
    l3=find((HD(i)+0.3)==S_num);
    l4=find((HD(i)+0.1)==C_num);
    if(~isempty(l1))
%         if(~isempty(l11))
            if(~isempty(l2))
                if(~isempty(l3))
                    if(~isempty(l4))
                        D(ii,1)=HD(i);
                        D(ii,2)=PR(l1);
                        D(ii,3)=find(PR(l1)==LRPR);
                        ii=ii+1;
                    end
%                 end
            end
        end
    end
end
Auc=[];
Normal_rank=[];
Normal_pr=[];
Normal_id=[];
Circle=1000;
% M_num=unique(used_M(:,2));
% normal_genes_all=intersect(intersect((D_num-0.2),(S_num-0.3)),intersect((C_num-0.1),(M_num-0.4)));
normal_genes_all=intersect(intersect((D_num-0.2),(S_num-0.3)),(C_num-0.1));
Candidate_normal=setdiff(normal_genes_all,D(:,1));

for(count=1:Circle)
Rand_loc_p=randperm(length(Candidate_normal),length(D));
Rand_gene_ID=Candidate_normal(Rand_loc_p);
nor=[];ii=1;
for(i=1:length(Rand_loc_p))
    l1=find((Rand_gene_ID(i)+0.4)==Reg_node);
    if(~isempty(l1))
        nor(ii,1)=Rand_gene_ID(i);
        nor(ii,2)=PR(l1);
        nor(ii,3)=find(PR(l1)==LRPR);
        ii=ii+1;
    end
end
% 存储一下rank
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
%
mdlSVM = fitcsvm(data_p,y_p,'Standardize',true);
mdlSVM = fitPosterior(mdlSVM);
[~,score_svm] = resubPredict(mdlSVM);
[Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(y_p,score_svm(:,mdlSVM.ClassNames),'true');
% clf;
% 画图
% H=figure;
% set(H,'Position',[4 402 560 420])
% axis square
% H1=plot(Xsvm,Ysvm,'o');
% set(H1,'markersize',6,'markeredgecolor','m','markerfacecolor','w')
% hold on,
% plot(Xsvm,Ysvm)
% hold off
% xlabel('False positive rate (1-Specificity)')
% ylabel('True positive rate (Sensitivity)')
% title(sprintf('(AUC=%0.4f)',AUCsvm))
Auc(count)=AUCsvm;
end
boxplot(Auc)
max(Auc)
mean(Auc)
min(Auc)
length(find(Auc>0.7))
length(find(Auc<0.6))
std(Auc)
%  save('RDSC_4_33_new.mat','D','Auc','Normal_id','Normal_pr','Normal_rank','-v6')
% save RDSC_4
median(Auc)
% save RDSC_4_33
clear
load  RDSC_4_33.mat
Auc_store=Auc';
LM=find(Auc==max(Auc));
nor_rank_max=Normal_rank(:,LM);
D_rank_f=D(:,3);
data_p=[];
for(i=1:(2*(length(D_rank_f))))
    if(i<=length(D_rank_f))
   data_p(i,1) =D_rank_f(i);%disease 
    else
       data_p(i,1) = nor_rank_max(i-length(D_rank_f)); % normal 
    end
end
y_p=(1:(2*(length(D_rank_f))))'>(length(D_rank_f));
%
mdlSVM = fitcsvm(data_p,y_p,'Standardize',true);
mdlSVM = fitPosterior(mdlSVM);
[~,score_svm] = resubPredict(mdlSVM);
[Xsvm1,Ysvm1,Tsvm,AUCsvm] = perfcurve(y_p,score_svm(:,mdlSVM.ClassNames),'true');
% clf;
H=figure;
set(H,'Position',[4 402 560 420])
axis square
plot(Xsvm1,Ysvm1,'-','LineWidth',0.05,'Color',[0.94 0.94 0.94])
xlabel('False positive rate (1-Specificity)')
ylabel('True positive rate (Sensitivity)')
% title(sprintf('(AUC=%0.4f)',AUCsvm))
%% 画AUC最小的ROC
LM=find(Auc==min(Auc));
nor_rank_max=Normal_rank(:,LM);
D_rank_f=D(:,3);
data_p=[];
for(i=1:(2*(length(D_rank_f))))
    if(i<=length(D_rank_f))
   data_p(i,1) =D_rank_f(i);%disease 
    else
       data_p(i,1) = nor_rank_max(i-length(D_rank_f)); % normal 
    end
end
y_p=(1:(2*(length(D_rank_f))))'>(length(D_rank_f));

mdlSVM = fitcsvm(data_p,y_p,'Standardize',true);
mdlSVM = fitPosterior(mdlSVM);
[~,score_svm] = resubPredict(mdlSVM);
[Xsvm2,Ysvm2,Tsvm,AUCsvm] = perfcurve(y_p,score_svm(:,mdlSVM.ClassNames),'true');
hold on,
plot(Xsvm2,Ysvm2,'-','LineWidth',0.05,'Color',[0.94 0.94 0.94])
fill(Xsvm1,Ysvm1,[0.94,0.94,0.94])
fill(Xsvm2,Ysvm2,'w')
%% 画median AUC的ROC
% LM=find(Auc==mean(Auc));
LM=find(Auc==median(Auc));
nor_rank_max=Normal_rank(:,LM);
D_rank_f=D(:,3);
data_p=[];
for(i=1:(2*(length(D_rank_f))))
    if(i<=length(D_rank_f))
   data_p(i,1) =D_rank_f(i);%disease 
    else
       data_p(i,1) = nor_rank_max(i-length(D_rank_f)); % normal 
    end
end
y_p=(1:(2*(length(D_rank_f))))'>(length(D_rank_f));
%
mdlSVM = fitcsvm(data_p,y_p,'Standardize',true);
mdlSVM = fitPosterior(mdlSVM);
[~,score_svm] = resubPredict(mdlSVM);
[Xsvm3,Ysvm3,Tsvm,AUCsvm] = perfcurve(y_p,score_svm(:,mdlSVM.ClassNames),'true');
hold on,
plot(Xsvm3,Ysvm3,'LineWidth',1,'Color',[1 0 0])
%%
box off
title('ROC curve of RDSC','fontsize',12,'fontname','Times New Roman','FontWeight','bold')
set(gca,'fontsize',12,'fontname','Times New Roman','FontWeight','bold');
axis([-0.05 1 -0.05 1])