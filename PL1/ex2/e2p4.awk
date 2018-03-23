BEGIN{}
NF>0{
    palavra = tolower($2)
    lema = tolower($3)
    pos = tolower($5)

    # Avoid repeating entries
    if(!((palavra lema pos) in arrayaux)){      
        
        # Mark this combination as found to avoid repetitions
        arrayaux[palavra lema pos] = 1

        # Initialize dictionary entry for this word
        if (!(palavra in array)) {
            array[palavra] = ""
        } else {

            # Add comma
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