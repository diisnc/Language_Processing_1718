# Determinar o dicionário implícito com (lema, pos)
#
# As colunas presentes são: palavra, secção, semestre, lema, pos(part of speech),
# tempoVerbal-modo, num-pessoa, Género, árvore, etc.
#
# É feito cuidado especial para que combinações de palavra + lema + pos não se repitam.
# Cada linha de output deste programa é imprimida no formato palavra:(lema,pos),(lema,pos),(lema,pos),[...]

# Example usage:
#   awk -f e1p4.awk micro.txt | sort | column -t -s ":"
#   (check e1p2.awk for more details on the command)
#   Note: the "column" part escachates on my pc.

BEGIN {
  # FS=" "
  # By default, FS is set to a single space character, which awk interprets to mean "one or more spaces or tabs."

  # Arrays used:
  # array[palavra] = string of (lema,pos),(lema,pos),[...] found associated with word
  # arrayaux[palavra lema pos] = 1 if combination has been found before
}

# Catch lines with lema and pos columns
# pos is $5, so check for at least 5 columns
NF >= 5 {

  palavra = tolower($1)
  lema = tolower($4)
  pos = $5

  # Avoid repeating entries
  if (!((palavra lema pos) in arrayaux)) {

    # Mark this combination as found to avoid repetitions
    arrayaux[palavra lema pos] = 1

    # Initialize dictionary entry for this word
    if (!(palavra in array)) {
      array[palavra] = ""
    } else {
      # Add comma
      array[palavra] = array[palavra] ","
    }

    # Esta lista de parts of speech por extenso não é exaustiva
    if (pos == "V") {
      pos = "Verbo"
    } else if (pos == "N") {
      pos = "Nome"
    } else if (pos == "ADJ") {
      pos = "Adjetivo"
    } else if (pos == "ADV") {
      pos = "Advérbio"
    } else if (pos == "DET_artd") {
      pos = "Determinante artigo definido"
    } else if (pos == "DET_arti") {
      pos = "Determinante artigo indefinido"
    } else if (pos == "NUM_year_date_card") {
      pos = "Número cardinal ano/data"
    } else if (pos == "NUM_card") {
      pos = "Número cardinal"
    }

    # Commas between the various (lema,pos) are added above
    array[palavra] = array[palavra] "(" lema "," pos ")"
  }
}

END {
  for (i in array) {
    print i ":" array[i]
  }
}
