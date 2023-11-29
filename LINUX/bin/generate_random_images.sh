#!/usr/bin/env bash

for i in {001..100}
do
    mx="${1}";my="${2}";head -c "$((3*mx*my))" /dev/urandom | convert -depth 8 -size "${mx}x${my}" RGB:- random$i.jpg
done
