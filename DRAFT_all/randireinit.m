function r = randireinit(imax)
seed = 0;

while seed == 0
   seed = clock;
   seed = floor(seed(6));
end

r = floor(imax*randi(seed)/seed);
end