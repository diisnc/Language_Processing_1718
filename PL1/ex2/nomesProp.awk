BEGIN{}

/noun.*proper/{nomes[$3]++;}

END{	
	for(ind in nomes){
		print nomes[ind], "::", ind
	}
}

#antes estava $6~/noun.*proper/{nomes[$3]++;} -> RELATORIO


