# Contar número de extratos, parágrafos, e frases.

BEGIN {
  # FS=" "
  # By default, FS is set to a single space character, which awk interprets to mean "one or more spaces or tabs."
  ext=0
  p=0
  s=0
}

/<\/ext>/ {
  ext++
}

/<\/p>/ {
  p++
}

/<\/s>/ {
  s++
}

END {
  print "Extratos (<ext>): " ext
  print "Paragrafos (<p>): " p
  print "Frases (<s>): " s
}
