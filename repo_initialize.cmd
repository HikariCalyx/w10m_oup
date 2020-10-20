@echo off
if not exist repo md repo
bin\aria2c -c -i db\filelist.txt --dir=repo\