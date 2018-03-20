BEGIN{}
NF>0{
        $6~/\=verb/{verbos[$3]++;}
        $6~/noun/{nomes[$3]++;}
        $6~/adjective/{adjectivos[$3]++;}
        $6~/adverb/{adverbios[$3]++;}
}
END{
        print("--------------------------------$VERBOS--------------------------------")
        for(ind in verbos){print ind}
        print("\n")
        print("--------------------------------$NOMES--------------------------------")
        for(ind in nomes){print ind}
        print("\n")
        print("--------------------------------$ADJECTIVOS--------------------------------")
        for(ind in adjectivos){print ind}
        print("\n")
        print("--------------------------------$ADVERBIOS--------------------------------")
        for(ind in adverbios){print ind}
}

