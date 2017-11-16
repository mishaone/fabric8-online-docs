CURRENT_DIR="$( pwd -P)"
SCRIPT_SRC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
OUTPUT_DIR=../../html
DOCS_SRC="$( dirname $SCRIPT_SRC )/docs"
BUILD_RESULTS="Build Results:"
BUILD_MESSAGE=$BUILD_RESULTS

# Move to docs dir
cd $DOCS_SRC

echo "=== Building Guides ==="
# Recurse through the guide directories and build them.
subdirs=`find . -maxdepth 1 -type d ! -iname ".*" ! -iname "topics" | sort`

echo $PWD
for subdir in $subdirs
do
  echo "Building $DOCS_SRC/${subdir##*/}"
  # Navigate to the dirctory and build it
  if ! [ -e $DOCS_SRC/${subdir##*/} ]; then
    BUILD_MESSAGE="$BUILD_MESSAGE\nERROR: $DOCS_SRC/${subdir##*/} does not exist."
    continue
  fi
  cd $DOCS_SRC/${subdir##*/}
  GUIDE_NAME=${PWD##*/}

  asciidoctor master.adoc -o $OUTPUT_DIR/$GUIDE_NAME.html
  asciidoctor -r asciidoctor-pdf -a imagesdir="topics/images" -b pdf master.adoc -o $OUTPUT_DIR/$GUIDE_NAME.pdf

  if [ "$?" = "1" ]; then
    BUILD_ERROR="ERROR: Build of $GUIDE_NAME failed. See the log above for details."
    BUILD_MESSAGE="$BUILD_MESSAGE\n$BUILD_ERROR"
  fi
  # Return to the parent directory
  #cd $SCRIPT_SRC
done

if [ -d $OUTPUT_DIR/images/ ]; then rm -r $OUTPUT_DIR/images/; fi
if [ -d topics/images/ ]; then cp -r topics/images/ $OUTPUT_DIR/images/; fi

chmod -R a+rwX $OUTPUT_DIR/

# Return to where we started as a courtesy.
cd $CURRENT_DIR
