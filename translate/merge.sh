#!/bin/bash

DIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
plasmoidName=`kreadconfig5 --file="$DIR/../metadata.desktop" --group="Desktop Entry" --key="X-KDE-PluginInfo-Name"`
widgetName="${plasmoidName
website=`kreadconfig5 --file="$DIR/../metadata.desktop" --group="Desktop Entry" --key="X-KDE-PluginInfo-Website"`
bugAddress="$website"
packageRoot=".." 
projectName="plasma_applet_${plasmoidName}" 

if [ -z "$plasmoidName" ]; then
	echo "[merge] Error: Couldn't read plasmoidName."
	exit
fi

if [ -z "$(which xgettext)" ]; then
	echo "[merge] Error: xgettext command not found. Need to install gettext"
	echo "[merge] Running 'sudo apt install gettext'"
	sudo apt install gettext
	echo "[merge] gettext installation should be finished. Going back to merging translations."
fi

echo "[merge] Extracting messages"
potArgs="--from-code=UTF-8 --width=200 --add-location=file"

find "${packageRoot}" -name '*.desktop' | sort > "${DIR}/infiles.list"
xgettext \
	${potArgs} \
	--files-from="${DIR}/infiles.list" \
	--language=Desktop \
	-D "${packageRoot}" \
	-D "${DIR}" \
	-o "template.pot.new" \
	|| \
	{ echo "[merge] error while calling xgettext. aborting."; exit 1; }

sed -i 's/"Content-Type: text\/plain; charset=CHARSET\\n"/"Content-Type: text\/plain; charset=UTF-8\\n"/' "template.pot.new"

find "${packageRoot}" -name '*.cpp' -o -name '*.h' -o -name '*.c' -o -name '*.qml' -o -name '*.js' | sort > "${DIR}/infiles.list"
xgettext \
	${potArgs} \
	--files-from="${DIR}/infiles.list" \
	-C -kde \
	-ci18n \
	-ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 \
	-kki18n:1 -kki18nc:1c,2 -kki18np:1,2 -kki18ncp:1c,2,3 \
	-kxi18n:1 -kxi18nc:1c,2 -kxi18np:1,2 -kxi18ncp:1c,2,3 \
	-kkxi18n:1 -kkxi18nc:1c,2 -kkxi18np:1,2 -kkxi18ncp:1c,2,3 \
	-kI18N_NOOP:1 -kI18NC_NOOP:1c,2 \
	-kI18N_NOOP2:1c,2 -kI18N_NOOP2_NOSTRIP:1c,2 \
	-ktr2i18n:1 -ktr2xi18n:1 \
	-kN_:1 \
	-kaliasLocale \
	--package-name="${widgetName}" \
	--msgid-bugs-address="${bugAddress}" \
	-D "${packageRoot}" \
	-D "${DIR}" \
	--join-existing \
	-o "template.pot.new" \
	|| \
	{ echo "[merge] error while calling xgettext. aborting."; exit 1; }

sed -i 's/
sed -i 's/

if [ -f "template.pot" ]; then
	newPotDate=`grep "POT-Creation-Date:" template.pot.new | sed 's/.\{3\}$
	oldPotDate=`grep "POT-Creation-Date:" template.pot | sed 's/.\{3\}$
	sed -i 's/'"${newPotDate}"'/'"${oldPotDate}"'/' "template.pot.new"
	changes=`diff "template.pot" "template.pot.new"`
	if [ ! -z "$changes" ]; then
		sed -i 's/'"${oldPotDate}"'/'"${newPotDate}"'/' "template.pot.new"
		mv "template.pot.new" "template.pot"

		addedKeys=`echo "$changes" | grep "> msgid" | cut -c 9- | sort`
		removedKeys=`echo "$changes" | grep "< msgid" | cut -c 9- | sort`
		echo ""
		echo "Added Keys:"
		echo "$addedKeys"
		echo ""
		echo "Removed Keys:"
		echo "$removedKeys"
		echo ""

	else
		rm "template.pot.new"
	fi
else
	mv "template.pot.new" "template.pot"
fi

potMessageCount=`expr $(grep -Pzo 'msgstr ""\n(\n|$)' "template.pot" | grep -c 'msgstr ""')`
echo "|  Locale  |  Lines  | % Done|" > "./Status.md"
echo "|----------|---------|-------|" >> "./Status.md"
entryFormat="| %-8s | %7s | %5s |"
templateLine=`perl -e "printf(\"$entryFormat\", \"Template\", \"${potMessageCount}\", \"\")"`
echo "$templateLine" >> "./Status.md"

rm "${DIR}/infiles.list"
echo "[merge] Done extracting messages"

echo "[merge] Merging messages"
catalogs=`find . -name '*.po' | sort`
for cat in $catalogs; do
	echo "[merge] $cat"
	catLocale=`basename ${cat%.*}`

	widthArg=""
	catUsesGenerator=`grep "X-Generator:" "$cat"`
	if [ -z "$catUsesGenerator" ]; then
		widthArg="--width=400"
	fi

	cp "$cat" "$cat.new"
	sed -i 's/"Content-Type: text\/plain; charset=CHARSET\\n"/"Content-Type: text\/plain; charset=UTF-8\\n"/' "$cat.new"

	msgmerge \
		${widthArg} \
		--add-location=file \
		--no-fuzzy-matching \
		-o "$cat.new" \
		"$cat.new" "${DIR}/template.pot"

	sed -i 's/
	sed -i 's/
	sed -i 's/

	poEmptyMessageCount=`expr $(grep -Pzo 'msgstr ""\n(\n|$)' "$cat.new" | grep -c 'msgstr ""')`
	poMessagesDoneCount=`expr $potMessageCount - $poEmptyMessageCount`
	poCompletion=`perl -e "printf(\"%d\", $poMessagesDoneCount * 100 / $potMessageCount)"`
	poLine=`perl -e "printf(\"$entryFormat\", \"$catLocale\", \"${poMessagesDoneCount}/${potMessageCount}\", \"${poCompletion}%\")"`
	echo "$poLine" >> "./Status.md"

	mv "$cat.new" "$cat"
done
echo "[merge] Done merging messages"

echo "[merge] Updating .desktop file"

if [ -f "$DIR/LINGUAS" ]; then
	rm "$DIR/LINGUAS"
fi
touch "$DIR/LINGUAS"
for cat in $catalogs; do
	catLocale=`basename ${cat%.*}`
	echo "${catLocale}" >> "$DIR/LINGUAS"
done

cp -f "$DIR/../metadata.desktop" "$DIR/template.desktop"
sed -i '/^Name\[/ d; /^GenericName\[/ d; /^Comment\[/ d; /^Keywords\[/ d' "$DIR/template.desktop"

msgfmt \
	--desktop \
	--template="$DIR/template.desktop" \
	-d "$DIR/" \
	-o "$DIR/new.desktop"

if [ ! -z "$(grep '^Name=$' "$DIR/new.desktop")" ]; then
	echo "[merge] Name in metadata.desktop is empty!"
	sed -i '/^Name\[/ d' "$DIR/new.desktop"
fi
if [ ! -z "$(grep '^GenericName=$' "$DIR/new.desktop")" ]; then
	echo "[merge] GenericName in metadata.desktop is empty!"
	sed -i '/^GenericName\[/ d' "$DIR/new.desktop"
fi
if [ ! -z "$(grep '^Comment=$' "$DIR/new.desktop")" ]; then
	echo "[merge] Comment in metadata.desktop is empty!"
	sed -i '/^Comment\[/ d' "$DIR/new.desktop"
fi
if [ ! -z "$(grep '^Keywords=$' "$DIR/new.desktop")" ]; then
	echo "[merge] Keywords in metadata.desktop is empty!"
	sed -i '/^Keywords\[/ d' "$DIR/new.desktop"
fi

translatedLines=`cat "$DIR/new.desktop" | grep "]="`
if [ ! -z "${translatedLines}" ]; then
	sed -i '/^Name\[/ d; /^GenericName\[/ d; /^Comment\[/ d; /^Keywords\[/ d' "$DIR/new.desktop"
	if [ "$(tail -c 2 "$DIR/new.desktop" | wc -l)" != "2" ]; then
		echo "" >> "$DIR/new.desktop"
	fi
	echo "${translatedLines}" >> "$DIR/new.desktop"
fi

mv "$DIR/new.desktop" "$DIR/../metadata.desktop"
rm "$DIR/template.desktop"
rm "$DIR/LINGUAS"

echo "[merge] Updating translate/ReadMe.md"
sed -i -E 's`share\/plasma\/plasmoids\/(.+)\/translate`share/plasma/plasmoids/'"${plasmoidName}"'/translate`' ./ReadMe.md
if [[ "$website" == *"github.com"* ]]; then
	sed -i -E 's`\[new issue\]\(https:\/\/github\.com\/(.+)\/(.+)\/issues\/new\)`[new issue]('"${website}"'/issues/new)`' ./ReadMe.md
fi
sed -i '/^|/ d' ./ReadMe.md 
cat ./Status.md >> ./ReadMe.md
rm ./Status.md

echo "[merge] Done"
