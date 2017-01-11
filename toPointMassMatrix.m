function M = toPointMassMatrix(consistentM)
    M = diag(sum(consistentM,2));
end