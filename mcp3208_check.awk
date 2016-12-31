{a[$1]++}
END{
 fail=0
 if (a["0111"]<3) fail=1
 if (a["1222"]<3) fail=1
 if (a["2123"]<3) fail=1
 if (a["3456"]<3) fail=1
 if (a["4678"]<3) fail=1
 if (a["59ab"]<3) fail=1
 if (a["6cde"]<3) fail=1
 if (a["7fef"]<3) fail=1
 if (fail) {print("FAIL"); exit 1;}
 print "PASS"
}
