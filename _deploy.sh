#!/bin/sh

git config --global user.name "Rafael Coelho"
git config --global user.email "rafael.coelho.x@gmail.com"

git clone -b content https://${TR_TOKEN}@github.com/R4CS/material.git deploy

cd deploy
cp -r ../content/* ./

git add -A
git commit -m "Atualização Material"
git push origin content
