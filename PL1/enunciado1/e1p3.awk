# Calcule a lista dos verbos PT: (Lema, para palavras com pos=V) e respetivo número de ocorrências.
#
# As colunas presentes são: palavra, secção, semestre, lema, pos(part of speech),
# tempoVerbal-modo, num-pessoa, Género, árvore, etc.

# Example usage:
#   awk -f e1p3.awk micro.txt | sort -k 2 -t "," -g | column -t -s ","
#   (check e1p2.awk for more details on the command)

BEGIN {
  # FS=" "
  # By default, FS is set to a single space character, which awk interprets to mean "one or more spaces or tabs."
}

# Catch words with part of speech == V
$5 == "V" {
  lema = tolower($4) # lema is $4 (make sure it's lowercase)
  array[lema]++      # increment count (defaults to 0 when uninitialized)
}

END {
  for (i in array) {
    print i "," array[i]
  }
}
