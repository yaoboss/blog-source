#!/bin/bash

hexo clean

git add .

git commit -m "blog update"

git push

hexo clean

hexo deploy