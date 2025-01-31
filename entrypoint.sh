#!/bin/bash -el

cd "$INPUT_BUILD_ROOT_DIR"

wget "https://github.com/JakeWharton/dependency-tree-diff/releases/download/$INPUT_VERSION/dependency-tree-diff.jar" -q -O dependency-tree-diff.jar

./gradlew $ADDITIONAL_GRADLE_ARGUMENTS projects
./gradlew $ADDITIONAL_GRADLE_ARGUMENTS :"$INPUT_PROJECT":dependencies --configuration "$INPUT_CONFIGURATION" >new_diff.txt
git fetch --force origin "$INPUT_BASEREF":"$INPUT_BASEREF" --no-tags
git switch --force "$INPUT_BASEREF"
./gradlew $ADDITIONAL_GRADLE_ARGUMENTS :"$INPUT_PROJECT":dependencies --configuration "$INPUT_CONFIGURATION" >old_diff.txt

diff=$(java -jar dependency-tree-diff.jar old_diff.txt new_diff.txt)
diff="${diff//'%'/'%25'}"
diff="${diff//$'\n'/'%0A'}"
diff="${diff//$'\r'/'%0D'}"
echo "::set-output name=text-diff::$diff"
