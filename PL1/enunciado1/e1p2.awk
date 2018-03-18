# Contar número de ocorrências de cada multi word expression.
# Está em inglês pq eu sou fix 8)
#
# Este script é mucho simples, sempre que acabamos de capturar uma multi word expression
# incrementamos array no indíce igual a essa multi word expression. Isto é facilitado
# pelo facto de que se esse indíce ainda não existir, é automaticamente inicializado a zero.
#
# Depois de terminar, reparei que estávamos a contar algumas expressões idênticas
# como diferentes por causa das maiúsculas. Por essa razão, adicionamos tolower()

# Example usage of this awk script:
#   awk -f e1p2.awk micro.txt | sort -k 2 -t "," -g | column -t -s ","
#
# This command has 3 main parts:
#
#   awk -f e1p2.awk micro.txt
#
#     Runs this awk script, outputting one multi word expression and the number
#     of times it appeared per line, in the format "multi word expression,count"
#
#   sort -k 2 -t "," -g
#
#     Sends the awk output to sort, for the lines to be sorted:
#       -k 2   Selects the second column, the count, to be used for ordering
#       -t "," Sets a comma as the column delimiter
#       -g     Sorts numerically (as opposed to alphabetically)
#
#   column -t -s ","
#
#     Sends the output of sort to column, to pretty print the results:
#       -t     Tells column to print data as a table
#       -s "," Sets a comma as the column delimiter

BEGIN {
  # FS=" "
  # By default, FS is set to a single space character, which awk interprets to mean "one or more spaces or tabs."

  capture=0 # Equal to 1 when we should be capturing a multi word expression

  justfinished=0 # Equal to 1 when we just finished capturing a multi word expression,
                 # and should increment its counter

  mwe="" # Will hold the captured multi word expression
}

# Catch all </mwe> and end capture
/<\/mwe>/ {
  capture=0
  justfinished=1
}

# Capture is on, add current word to mwe
capture == 1 {
  mwe = mwe " " tolower($1)
}

# Just finished catching a multi word expression (reached </mwe>),
# increment the counter and reset mwe
justfinished == 1 {
  justfinished=0
  array[mwe]++
  mwe=""
}

# Catch all <mwe [...]> tags and turn on capture flag
# This is the last block so we only start capturing on
# the next record
/<mwe.*>/ {
  capture=1
}

END {
  for (i in array) {
    print i "," array[i]
  }
}
