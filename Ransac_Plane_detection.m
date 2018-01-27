close all;
clear all;
clc;

data = dlmread('Charite-2planes.ptx');

x = data(11:end,1);
y = data(11:end,2);
z = data(11:end,3);

cloud = [x y z];
points = length(cloud);
cloud = [cloud  (zeros(points,1))];
extended_cloud = [cloud (zeros(points,1))];

final = zeros(points,4);
maxPosDist = 0.01; % the maximum distance that a point of the point cloud is allowed to have from a plane
iterations = 0;
maxIter = 200;%maximum iterations
nr_planes = 1;%count planes
l=1;%counter for final results table

%Iterations
while iterations<maxIter && points>5999
      
   %Randomly select 3 points
   %First point
   randLoc1=randi(points);
   randPoint1(1,:)=cloud(randLoc1,1:3);
   
   %Check for selecting the rest 2 points
   randLoc2=randLoc1;
   while randLoc2==randLoc1
       randLoc2=randi(points);
       randPoint2(1,:)=cloud(randLoc2,1:3);
   end
   
   %Third point
   randLoc3=randLoc1;
   while randLoc3==randLoc1 || randLoc3==randLoc2
       randLoc3=randi(points);
       randPoint3(1,:)=cloud(randLoc3,1:3);
   end
   
   % Determine the plane created by the three randomly selected points
   vector = cross((randPoint2-randPoint1),(randPoint3-randPoint1));
   n = vector/norm(vector);
   
   %Find points that belong to the determined plane
   nr_points_perPlane = 3;
   for i = 1:points 
      dist(i,1) = abs((cloud(i,1:3) - randPoint3(1,:))*n');
      if dist(i,1)<= maxPosDist
          cloud(i,4)= nr_planes;
          extended_cloud(i,4)= nr_planes;
          nr_points_perPlane = nr_points_perPlane+1; %count points in this plane
          final(l,:) = cloud(i,:);
          l=l+1;
      end
   end
    
   iterations = iterations + 1; 
   cloud(cloud(:,4)==nr_planes,:)=[];
   points = length(cloud);
   
   % Check if points in this plane are adequate to suppose that this plane
   % is valid
    if nr_points_perPlane < 6000
       for i = 1:points
           if extended_cloud(i,4)== nr_planes
                  extended_cloud(i,4)=0;
                  cloud(i,4)=0;
           end
       end
    else
        nr_planes=nr_planes+1; %increase amount of detected planes if this plane is valid
    end
       
end

for i=1:nr_planes
   total(i,1)=i;
   total(i,2)=sum(final(:,4)==i-1); 
end

pointsInPlanes = sum(total(:,2));
fin_size = length(final);

final = [final zeros(fin_size,1) zeros(fin_size,1) zeros(fin_size,1)];

% Give random colour
for i = 0:nr_planes
    randColor = randi([0 255], 3, 1);
    final((final(:,4)==i),5) = randColor(1,1);
    final((final(:,4)==i),6) = randColor(2,1);
    final((final(:,4)==i),7) = randColor(3,1);
end
color_cloud1 = final(:,1:3);
color_cloud2 = final(:,5:7);
color_cloud = [color_cloud1 color_cloud2];
dlmwrite('2planes.txt', color_cloud);




