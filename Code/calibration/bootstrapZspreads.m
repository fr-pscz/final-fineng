function Z = bootstrapZspreads(MKTBOND,PD)

Z = getZeta(MKTBOND(1), PD);

for ii = 2:numel(MKTBOND)
    Z = getZeta(MKTBOND(ii), PD, Z);
end

end
