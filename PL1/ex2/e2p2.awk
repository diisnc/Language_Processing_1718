BEGIN{}

/noun.*proper/{nomes[$3]++;}

END{	
	for(ind in nomes){
		print ind, nomes[ind]
	}
}

#antes estava $6~/noun.*proper/{nomes[$3]++;} -> RELATORIO