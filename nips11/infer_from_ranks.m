function infer_from_ranks
%In this example, we do learning from partial rank data
%Tomasz Malisiewicz (tomasz@cmu.edu)

%Number of questions to answer
N = 10000;

%Number of objects
K = 30;

%Probability of making a mistake
pmistake = 0.0;

[x,d] = generate_point_distance_matrix(K);
[triplets,y] = generate_triplets(d,N);
[triplets2,y2] = generate_triplets(d,N);

%Add nose to some of the examples
subset = find(rand(size(y))<pmistake);
y(subset) = y(subset)*-1;

xs = zeros(K*K,4*N);
y = zeros(1,4*N);
c = 1;
for i = 1:N
  delta_ab = zeros(K,K);
  delta_ab(triplets(1,i), triplets(2,i)) = 1;
  
  delta_ac = zeros(K,K);
  delta_ac(triplets(1,i), triplets(3,i)) = 1;
  xs(:,c+0) = reshape(delta_ac' - delta_ab, [], 1);
  %xs(:,c+1) = reshape(delta_ac' - delta_ab',[], 1);
  %xs(:,c+2) = reshape(delta_ac  - delta_ab',[], 1);
  %xs(:,c+3) = reshape(delta_ac  - delta_ab, [], 1);  
  y(c+0) = 1;
  %y(c+1) = 1;
  %y(c+2) = 1;
  %y(c+3) = 1;
  c = c + 1;
end


wpos = 1.0;
model = liblinear_train(y', -sparse(xs)', ...
                        sprintf(['-s 3 -B -1 -c 10' ...
                    ' -w1 %.3f -q'],wpos));
if y(1) == -1
  model.w = model.w*-1;
end


d2=(reshape(model.w,K,K));
d2 = (d2+d2')/2;

figure(1)
subplot(2,2,1)
imagesc(d)
title('original distance matrix')
subplot(2,2,2)
imagesc(d2)
title('recovered distance matrix')

[u,w,v] = svd(d);
subplot(2,2,3)
plot(v(:,1),v(:,2),'r.');
title('gt points')

[u,w,v] = svd(d2);
subplot(2,2,4)
plot(u(:,1),u(:,2),'r.');
% i1=(sub2ind(size(d),ids(1,:),ids(2,:)));
% i2=(sub2ind(size(d),ids(1,:),ids(3,:)));
  
  
% j1=(sub2ind(size(d),ids2(1,:),ids2(2,:)));
% j2=(sub2ind(size(d),ids2(1,:),ids2(3,:)));


% drawnow


% %mean(d(i1) - d(i2)>=0)
% mean(d2(i1) - d2(i2)>=0)

% %mean(d(j1) - d(j2)>=0)
% mean(d2(j1) - d2(j2)>=0)

% subplot(2,2,3)
% [U,W,V] = svd(d);
% plot(U(:,2),U(:,3),'r.');
% title('original embedding')


% subplot(2,2,4)
% [U,W,V] = svd(d2);
% %Y = mdscale(d2,2);
% plot(U(:,1),U(:,2),'r.');
% title('recovered embedding')


function [x,d] = generate_point_distance_matrix(K)
%Generate points on circle as well as distance matrix

thetas = linspace(0,2*pi,K+1);
thetas = thetas(1:end-1);
x = [(thetas); thetas;];%sin(2*thetas)];

%d is the real distance matrix
d = distSqr_fast(x,x);

function [triplets,y] = generate_triplets(d,N)
%Given a distance matrix, generate N questions and answers
%The triplets are elements A B C: where d_AB > d_AC
triplets = zeros(3,N);
K = size(d,1);

for i = 1:N
  r = randperm(K);
  r = r(1:2);
  r2 = randperm(K);
  r = [r r2(1)];
  if d(r(1),r(2)) < d(r(1),r(3))
    r = r([1 3 2]);
  end
  
  triplets(:,i) = r;
end
y = ones(1,N);