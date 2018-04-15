#!/bin/sh

git clone -b content https://github.com/R4CS/material.git deploy

cd deploy
cp -r ../content/* ./

git add -A
git commit -m "Atualização Material"
git push origin content