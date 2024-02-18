#!/bin/bash

source <(secinit)

set -Eeu

SECFUNCexecA -ce cp -vf "ManaPotion.ftl.unpack" "MilkyPotion.ftl.unpack"

SECFUNCexecA -ce sed -i -r "s@ManaPotion.abstrato-arte-criativa-azul-misturada-text.jpg@ManaPotion.abstrato-arte-criativa-whitemisturada-text.jpg@i" "MilkyPotion.ftl.unpack"

egrep "ManaPotion.abstrato-arte-criativa.*misturada-text.jpg" *.ftl.* -iao
