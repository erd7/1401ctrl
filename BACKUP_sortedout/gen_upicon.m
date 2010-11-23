function r = gen_upicon()
   genmat = zeros(8,15,3) * NaN; %Discuss the effect of the third dimension; currently empty.
   m = 1;
   n = 0;

   for i=1:8
      genmat(m:8,8+n) = 0;
      genmat(m:8,8-n) = 0;
   
      m = m + 1;
      n = n + 1;
   end

   r = genmat;
   
end