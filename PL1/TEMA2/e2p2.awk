BEGIN{}
$6~/noun.*proper/{nomes[$2]++;}
END{for(ind in nomes){
	print ind, nomes[ind]}
}