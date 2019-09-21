#!/bin/sh

for TEXI in $(ls original_texis/*.texi)
do
    TEXI=$(basename ${TEXI})
    if [ -f ~/gitroot/emacs-26.2-doc-emacs/${TEXI}.po ];
    then
	
	# POTファイルの作成

	 po4a-gettextize \
	     -M utf8 \
	     -f texinfo \
	     -m original_texis/${TEXI} \
	     -p ${TEXI}.pot

	# 26.1.92翻訳をマージ
	msgmerge \
	    --previous --compendium ~/gitroot/emacs-26.2-doc-emacs/${TEXI}.po \
	    -o - /dev/null ${TEXI}.pot |
	    msgcat --no-wrap - > ${TEXI}.po
    fi
    
done
