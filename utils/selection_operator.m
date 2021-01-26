function y = selection_operator(x, locations, m, n, no_c)

x = reshape(x,m,n,no_c);

y = x(locations);
y = y(:);

end