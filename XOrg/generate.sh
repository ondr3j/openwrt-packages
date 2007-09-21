#!/bin/sh
for d in `find . -name packages`; do
	cd `dirname $d`
	echo "Entering "`dirname $d`
	for p in `cat packages`; do
		_NAME=${p%%|*}
		NAME=${_NAME%-*}
		BASE_NAME=${NAME%%-*}
		_VER=${_NAME##*-}
		VER=${_VER%%|*}
		DEP=`echo ${p##*|} | sed "s/+/ +/g"`
		echo generating Makefile for ${NAME}-${VER} with deps : ${DEP}
		rm -rf ${NAME} 
		mkdir ${NAME}
		sed "s/@VER@/${VER}/g" template.mk | sed "s/@DEP@/${DEP}/g" | sed "s/@NAME@/${NAME}/g" | sed "s/@BASE_NAME@/${BASE_NAME}/g" > ${NAME}/Makefile
		if [ -d `pwd`/patches/${NAME} ]; then
			mkdir ${NAME}/patches
			cp -r `pwd`/patches/${NAME}/* ${NAME}/patches/
		fi
	done
	cd - > /dev/null
done