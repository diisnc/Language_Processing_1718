# Contar número de extratos, parágrafos, e frases.

# Example:
# gawk -f exextra.awk -v word='governo' fl0.txt | sort -k 1 -n -r
# instead of governo you use any word you wanna search
# sort options: -k selects column (nr 1 in this case)
# -n orders by number
# -r reverses it

BEGIN {
  # FS=" "
  # By default, FS is set to a single space character, which awk interprets to mean "one or more spaces or tabs."
  exists=0
  word
  saveProx=0
  saved=0
  numSugestion=0
  sugestedWord
}

$2~/[a-zA-Z]+/ {

	# word after the one which we are looking for
	if(saveProx==1) {
		previsao[$2]++;
		saveProx=0;
		saved++;
	}

	# check if its the word we are looking for
	if(word==$2) {
		exists++;
		saveProx=1;
	}

}

END {
	for (i in previsao) {
    	print previsao[i] ":" i;
    	if (previsao[i] > numSugestion) {
    		numSugestion=previsao[i];
    		sugestedWord=i;
    	}
    }
    print "Encontrou " exists " " word
    print "#Previsoes: " saved
    print "Sugestao: " sugestedWord
}