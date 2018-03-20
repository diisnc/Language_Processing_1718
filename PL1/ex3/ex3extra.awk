# Contar número de extratos, parágrafos, e frases.

BEGIN {
  # FS=" "
  # By default, FS is set to a single space character, which awk interprets to mean "one or more spaces or tabs."
  linhas=0
}

{
  linhas++
}

END {
  print "Extratos (<ext>): " ext
  print "Paragrafos (<p>): " p
  print "Frases (<s>): " s
}
