#!/bin/bash

ansible -m copy -a "src=test.txt dest=/tmp/test.txt"