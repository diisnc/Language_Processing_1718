# Contar número de extratos, parágrafos, e frases.

BEGIN {
  # FS=" "
  # By default, FS is set to a single space character, which awk interprets to mean "one or more spaces or tabs."
  linhas=0
}

/[a-zA-Z]+/ {
  print;
}

 x=1 
    while ( x<NF ) { 
        print $x "\t" 
        x++ 
    } 

END {
  print linhas
}