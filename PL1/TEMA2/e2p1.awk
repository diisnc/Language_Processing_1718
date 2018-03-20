BEGIN{FS=" "; conta=0}
NF>0{conta++}
END{print conta}
