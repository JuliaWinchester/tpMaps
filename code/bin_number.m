function n = bin_number(num, i, j, binSize)
% BIN_NUMBER - Bin number in which ixj pairwise comparison would be located

	n = ceil((((i-1) * num) + j)/binSize);

end
