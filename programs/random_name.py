#!/usr/bin/env python3
from json import load as json_read
from sys import argv
from random import choice

# This is just a small script to generate a random name

def pick_randomly(l):
    pass

# First load the names from the JSON file
name_file = "../data/names.json"
f = open(name_file, 'r')
j = json_read(f)
f.close()

kind = argv[1]

for nlist in j[kind]:
    for subnlist in nlist:
        print(choice(subnlist), end='')
    print(' ', end='')
print()

