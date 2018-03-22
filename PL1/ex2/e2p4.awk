BEGIN{}
NF>0{
    palavra = tolower($2)
    lema = tolower($3)
    pos = tolower($5)

    if(!((palavra lema pos) in arrayaux)){      
        arrayaux[palavra lema pos] = 1

        if (!(palavra in array)) {
            array[palavra] = ""
        } else {
            array[palavra] = array[palavra] ","
        }

        array[palavra] = array[palavra] "(" lema "," pos ")"
    }
}
END{
    for(ind in array){
        print ind ":" array[ind]
    }

}

#dizer q n faz sentido fazer um dicionario q nao tenha pos