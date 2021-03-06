LIB_DESTINATION="../SAStorage.framework"

rm -rf "${LIB_DESTINATION}"

DERIVED="${HOME}/Library/Developer/Xcode/DerivedData/SAStorage-*"
for DERIVED_FOLDER in ${DERIVED}; do
	echo "Removing ${DERIVED_FOLDER}"
	rm -rf "${DERIVED_FOLDER}"
done


echo "Lipo'ing ${LIB_DESTINATION}"

mkdir -p "${LIB_DESTINATION}"
mkdir -p "${LIB_DESTINATION}/Versions/A"
mkdir -p "${LIB_DESTINATION}/Versions/A/Headers"
mkdir -p "${LIB_DESTINATION}/Versions/A/Resources"

lipo -create "build/Release-iphoneos/libSAStorage_Library.a" "build/Debug-iphonesimulator/libSAStorage_Library.a" -output "${LIB_DESTINATION}/Versions/A/SAStorage"

ln -s "${LIB_DESTINATION}/Versions/A/Headers/" "${LIB_DESTINATION}/Headers"
ln -s "${LIB_DESTINATION}/Versions/A/Resources/" "${LIB_DESTINATION}/Resources"
ln -s "${LIB_DESTINATION}/Versions/A/" "${LIB_DESTINATION}/Current"
ln -s "${LIB_DESTINATION}/Versions/A/SAStorage" "${LIB_DESTINATION}/SAStorage"



HEADERS="build/Debug-iphonesimulator/usr/local/include/*.h"
for HEADER in ${HEADERS}; do
	FILENAME="${HEADER##*/}"
	cp $HEADER "${LIB_DESTINATION}/Versions/A/Headers/${FILENAME}"
done
