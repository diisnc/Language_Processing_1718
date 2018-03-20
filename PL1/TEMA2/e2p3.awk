BEGIN{}
$6~/\=verb/{verbos[$2]++;}
$6~/noun/{nomes[$2]++;}
$6~/adjective/{adjectivos[$2]++;}
$6~/adverb/{adverbios[$2]++;}
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

