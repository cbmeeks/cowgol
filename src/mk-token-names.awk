BEGIN {
    # BIG WARNING! This size needs to account for RootThing.
    # Change if you add an entry to RootThing.
    count = 0xB
    print "const TOKEN_FLAG_PRECEDENCE_MASK := 0b0000_1111;"
    print "const TOKEN_FLAG_BINARY_OP       := 0b0001_0000;"
    print "const TOKEN_FLAG_PREFIX_OP       := 0b0010_0000;"
    print "const TOKEN_FLAG_POSTFIX_OP      := 0b0100_0000;"
    print "const TOKEN_FLAG_EXPR_ENDER      := 0b1000_0000;"
    print ""
}

/^[^ #].*$/ {
    printf "const TOKEN_%s := 0x%x;\n", $2, count
    if ($3 == "IDENTIFIER")
        count += 3
    else
        count += 4
}

/^ .*$/ {
    print "const TOKEN_" $1 " := " count ";"
    count += 4
}
