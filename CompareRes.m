%% 1 - load the three Results for the just checking stuff
% we are slightly worse here than greedy

res_own_f = load('Results_own_Algo.mat');
res_greedy_f = load('Results_Greedy_Algo.mat');
res_rand_f = load('Results_Random.mat');
res_own = res_own_f.step_counter;
res_greedy = res_greedy_f.step_counter;
res_rand = res_rand_f.step_counter;
combined = [res_own, res_greedy, res_rand];
mean_comb = mean(combined);
std_comb = std(combined);
x = 1:size(combined,1);
figure
plot(x,res_own,'g','DisplayName','own');
hold on
plot(x, res_greedy, 'r', 'DisplayName', 'greedy');
plot(x, res_rand, 'b', 'DisplayName', 'random');
hold off
legend()

%% 2 - Load the results for the probability of detection stuff
res_own_prob_f = load('Results_own_Algo_detect_prob.mat');
res_greedy_prob_f = load('Results_Greedy_Algo_detect_prob.mat');
res_rand_prob_f = load('Results_Random_detect_prob.mat');
res_own_prob = res_own_prob_f.step_counter;
res_greedy_prob = res_greedy_prob_f.step_counter;
res_rand_prob = res_rand_prob_f.step_counter;
combined_prob = [res_own_prob, res_greedy_prob, res_rand_prob];
mean_prob = mean(combined_prob);
std_prob = std(combined_prob);
x = 1:size(combined_prob,1);
figure
plot(x,res_own_prob,'g','DisplayName','own');
hold on
plot(x, res_greedy_prob, 'r', 'DisplayName', 'greedy');
plot(x, res_rand_prob, 'b', 'DisplayName', 'random');
hold off
legend()

%% Walking through the directory
directory = "Results";

no_of_simulations = 200;
max_r = 10;
ang_bins = 18;

% these can change
pt_count_threshold_bin = [4, 7, 10, 15];
dist_threshold = [0.5, 0.75, 1.0, 1.25];
intermediate_pts_ct = [2, 3, 5, 8];

% these are for plotting
Algorithms = ["Random", "Own", "Greedy"];
base_string = "%s-Maxr_%d-AngBins_%d-BinThresh-%d-DistThresh-%f-IntermPtsCt-%d.mat";
x = 1:no_of_simulations;
C = {'b','g','r'};

for i=1:size(pt_count_threshold_bin,2)
   for j=1:size(dist_threshold,2)
        for k=1:size(intermediate_pts_ct,2)
            figure
            for m = 1:length(Algorithms)
                fname = sprintf("%s-Maxr_%d-AngBins_%d-BinThresh-%d-DistThresh-%f-IntermPtsCt-%d.mat",...
                    Algorithms(m),max_r,ang_bins,...
                    pt_count_threshold_bin(i), dist_threshold(j), intermediate_pts_ct(k));
                filename = strcat(directory,"/",fname);
                f = load(filename);
                res = f.step_counter;
                plot(x,res,'color',C{m},'DisplayName',Algorithms(m));
                hold on
            end
            title(sprintf("Pts: %d, DistThresh: %f, Intermediate pts: %d",...
                pt_count_threshold_bin(i), dist_threshold(j), intermediate_pts_ct(k)))
            hold off
            legend()
        end
   end
end

%% PRELIMINARIES:

no_of_simulations = 200;
max_r = 10;
ang_bins = 18;

% 2.2 - these can change
pt_count_threshold_bin = [4, 7, 10, 15];
pt_count_thresh_str = cellstr(num2str(pt_count_threshold_bin'));
dist_threshold = [0.5, 0.75, 1.0, 1.25];
dist_tresh_str = cellstr(num2str(dist_threshold'));
intermediate_pts_ct = [1, 2, 3, 5, 8];
interm_pts_str = cellstr(num2str(intermediate_pts_ct'));
Algos = ["Own", "Greedy", "Random"];
C = {'b','g','r'};
LineStyle = {'-',':','-.','--'};
MarkerSymbol = {'o','x','+','v','^'};
len_algos = size(Algos,2);

% length of changeable stuff
len_pt_thresh = size(pt_count_threshold_bin,2);
len_dist_thresh = size(dist_threshold,2);
len_interm_ct = size(intermediate_pts_ct,2);
total_opt = len_pt_thresh * len_dist_thresh * len_interm_ct;

%% V3 SPL Bar Charts - Important part -SCALE Y-AXIS TO BE THE SAME
% quality is proportional to number of successses
% quality is INVERSELY proportional to number of steps
% ergo, q ~ succ# / steps

res = load("Result_Overview_SPL_V3.mat");
BigArray = res.BigArray;
figure
% rows, cols, pos
subplot(len_dist_thresh,len_interm_ct,1);
for i=1:len_dist_thresh
    for j=1:len_interm_ct
        ax = subplot(len_dist_thresh,len_interm_ct,(i-1)*len_interm_ct+j);
        mean = BigArray(:,:,i,j,4); % just change the number here to compare different values
%         std = BigArray(:,:,i,j,2);
        bar(ax, mean);
        ylim(ax, [0, 0.2])
        set(ax, 'XTickLabel',Algos)
        legend(pt_count_thresh_str)
        title_str = sprintf("Dist-thresh: %.2f, Interm-pts: %d",dist_threshold(i), intermediate_pts_ct(j));
        title(ax, title_str);
    end
end
sgtitle("Changing Pts-count Threshold - SPL - V3");
%% Plotting the successes
own_mean = BigArray(1,:,:,:,1);
own_success = BigArray(1,:,:,:,3);
greedy_mean = BigArray(2,:,:,:,1);
greedy_success = BigArray(2,:,:,:,3);
own_mean_vec = reshape(own_mean, [],1);
own_success_vec = reshape(own_success, [],1);
greedy_mean_vec = reshape(greedy_mean, [], 1);
greedy_success_vec = reshape(greedy_success, [], 1);
q_own = own_success_vec./own_mean_vec;
q_greedy = greedy_success_vec./greedy_mean_vec;
rand_mean = BigArray(3,:,:,:,1);
rand_success = BigArray(3,:,:,:,3);
rand_mean_vec = reshape(rand_mean, [], 1);
rand_success_vec = reshape(rand_success, [], 1);
q_rand = rand_success_vec./rand_mean_vec;
len = length(q_own);
x=1:len;
figure
plot(x,q_greedy,'r','Displayname','Greedy');
hold on
plot(x,q_own,'g','Displayname','Own');
plot(x,q_rand, 'b','Displayname','Random');
legend()
title("Number of successes divided by Mean steps for all 80 scenarios");
hold off
%% Section on newest - Bigger arrays with 2 extra dimensions - Look at section below for tips
% Big array to store it all - 
% 1st Dim - Algorithm - Order: Own, Greedy, Random
% 2nd Dim - pt_count_threshold
% 3rd Dim - dist-threshold
% 4th Dim - interm-pts-ct
% 5th Dim - Negative elements or not: 1 = with neg, 2 =without neg
% 6th Dim - random initialization or not q =1 with, q = 2 without
% 7th Dim - Mean, Std, successes
res = load("Result_Overview_SPL_Neg_Rand-Init-Switch.mat");
BigArray = res.BigArray;
figure
p = 2;
q = 1;
for i = 1:len_dist_thresh
   for j = 1:len_interm_ct
       for k = 1:len_algos
           % Get the mean of the algorithm
           mean_val = BigArray(k, :, i, j, p, q, 1);
           std_val = BigArray(k, :, i, j, p, q, 2);
           succ_ct = BigArray(k, :, i, j, p, q, 3);
           spl = BigArray(k, :, i, j, p, q, 4);
           qual = succ_ct./mean_val;
           linestyle_str = strcat(C{k}, MarkerSymbol(j), LineStyle(i));
           leg_str = sprintf('%s-%d-%.2f',Algos(k),intermediate_pts_ct(j), dist_threshold(i));
           plot(pt_count_threshold_bin, qual, char(linestyle_str),'DisplayName',leg_str);           %CONTINUE HERE - get the graphs with the different colours,
           %Linestyle(i)
           % markersymbol(j)
           hold on
       end
   end
end
ylabel("Q")
xlabel("Point Count Threshold")
title("Q over Point Count Threshold for varying Algorithms")
legend()
hold off

%% Bar graph section
figure
% rows, cols, pos
subplot(len_dist_thresh,len_interm_ct,1);
p=2; % p = 2 is without negative elements
q=1;
for i=1:len_dist_thresh
    for j=1:len_interm_ct
        ax = subplot(len_dist_thresh,len_interm_ct,(i-1)*len_interm_ct+j);
        mean = BigArray(:,:,i,j,p,q,4); % just change the number here to compare different values
%         std = BigArray(:,:,i,j,2);
        bar(ax, mean);
        ylim(ax, [0, 0.3])
        set(ax, 'XTickLabel',Algos)
        legend(pt_count_thresh_str)
        title_str = sprintf("Dist-thresh: %.2f, Interm-pts: %d",dist_threshold(i), intermediate_pts_ct(j));
        title(ax, title_str);
    end
end
sgtitle("Changing Pts-count Threshold - SPL - V3");

%% Section on making plots of different colors and shapes

% We have three variables. p = intermediate point count, distance
% threshold, pt count threshold

% pt count threshold has the least influence, looks fairly random/similar
% to me
% so just take one of those
rand_mean = BigArray(2,1,:,:,1);
rand_std = BigArray(2,1,:,:,2);
rand_successes = BigArray(2,1,:,:,3);
rand_spl = BigArray(2,1,:,:,4);

figure
for i = 1:len_dist_thresh
   for j = 1:len_interm_ct
       for k = 1:len_algos
           % Get the mean of the algorithm
           mean_val = BigArray(k, :, i, j, 1);
           std_val = BigArray(k, :, i, j, 2);
           succ_ct = BigArray(k, :, i, j, 3);
           spl = BigArray(k, :, i, j, 4);
           q = succ_ct./mean_val;
           linestyle_str = strcat(C{k}, MarkerSymbol(j), LineStyle(i));
           leg_str = sprintf('%s-%d-%.2f',Algos(k),intermediate_pts_ct(j), dist_threshold(i));
           plot(pt_count_threshold_bin, spl, char(linestyle_str),'DisplayName',leg_str);           %CONTINUE HERE - get the graphs with the different colours,
           %Linestyle(i)
           % markersymbol(j)
           hold on
       end
   end
end
ylabel("Q")
xlabel("Point Count Threshold")
title("Q over Point Count Threshold for varying Algorithms")
legend()
hold off

%% Using the Big Array - DEPRECATED
res = load("Result_Overview.mat");
BigArray = res.BigArray;

% 2 - All the things that can change
% 2.1 - not really - Simulation dependent


% Big array to store it all - 
% 1st Dim - Algorithm - Order: Own, Greedy, Random
% 2nd Dim - pt_count_threshold
% 3rd Dim - dist-threshold
% 4th Dim - interm-pts-ct
% 5th Dim - Mean, Std, successes, SPL


figure
% rows, cols, pos
subplot(len_dist_thresh,len_interm_ct,1);
for i=1:len_dist_thresh
    for j=1:len_interm_ct
        ax = subplot(len_dist_thresh,len_interm_ct,(i-1)*len_interm_ct+j);
        mean = BigArray(:,:,i,j,4);
%         std = BigArray(:,:,i,j,2);
        bar(ax, mean);
        set(ax, 'XTickLabel',Algos)
        legend(pt_count_thresh_str)
        title_str = sprintf("Dist-thresh: %.2f, Interm-pts: %d",dist_threshold(i), intermediate_pts_ct(j));
        title(ax, title_str);
    end
end
sgtitle("Changing Pts-count Threshold");

% Section for the number of successes
figure
subplot(len_dist_thresh, len_interm_ct,1);
for i=1:len_dist_thresh
   for j=1:len_interm_ct
       ax = subplot(len_dist_thresh,len_interm_ct,i-1+j);
       successes = BigArray(:,:,i,j,3);
       
   end
end

% x = 1:no_of_simulations;
% for i=1:len_algos
mean = BigArray(:,:,k,m,1);
std = BigArray(:,:,k,m,2);
successes = BigArray(:,:,k,m,3);
b = bar(mean);
hold on
er = errorbar(mean,std);
% hold on
set(gca, 'XTickLabel',Algos)
legend(pt_count_thresh_str)
title_str = sprintf("Changing Pts_count Thresh.\nKeeping constant: Dist-threshold: %f, Interm-pts-count: %d",dist_threshold(k), intermediate_pts_ct(m));
title(gca, title_str);
% end

figure
hBar = bar(mean, 0.8);
for k1=1:size(mean,1)
    ctr(k1,:) = bsxfun(@plus, hBar(k1).XData, hBar(k1).XOffset');
    ydt(k1,:) = hBar(k1).YData;
end
hold on
errorbar(ctr, ydt, std, '.r')