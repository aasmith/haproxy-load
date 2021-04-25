#!/bin/bash

# Because netcat is not detatching, take up all 3 input/output streams
# so that ssh at invocation-time doesn't sit around waiting forever
nohup nc -ul 8514 2> err.log > req.log < /dev/null &

echo "running logspout"
