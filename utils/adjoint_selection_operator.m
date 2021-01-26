function y = adjoint_selection_operator(x, locations, m,n,no_c)

space = zeros(m,n,no_c,'single');
space(locations) = x;
y = space(:);

end