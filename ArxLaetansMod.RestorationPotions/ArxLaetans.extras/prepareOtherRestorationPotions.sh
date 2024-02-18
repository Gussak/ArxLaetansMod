#!/bin/bash

source <(secinit)

set -Eeu

SECFUNCexecA -ce cp -vf "HealingPotion.ftl.unpack" "PoisonAntidote.ftl.unpack"

SECFUNCexecA -ce sed -i -r "s@HealingPotion.Liquid_Base_Color.jpeg@HealingPotion.Liquid_ColrPurple.jpeg@i" "PoisonAntidote.ftl.unpack"

egrep "HealingPotion.Liquid_.*.jpeg" *.ftl.* -iao
