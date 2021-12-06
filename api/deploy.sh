#!/bin/bash
echo "HTTP/1.0 200 OK"
echo "Content-type:text/plain"
echo ""
git pull 2>&1
echo "Test"
