function val = quadratur(fun,valSize)
    x1 = [-1/sqrt(3),1/sqrt(3)];
    x = combvec(x1,x1)';
    val = zeros(valSize);
    for i = 1:size(x,1)
            val = val+fun(x(i,:));
    end
end