function r = gen_dwnicon()
   genmat = zeros(8,15,3) * NaN; %Discuss the effect of the third dimension; currently empty.
   m = 0;
   n = 0;

   for i=1:8
      genmat(1:8-m,8+n) = 0;
      genmat(1:8-m,8-n) = 0;
   
      m = m + 1;
      n = n + 1;
   end

   r = genmat;
   
end