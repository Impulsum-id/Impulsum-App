bash
#!/bin/bash
# Install XcodeGen if it's not already installed
if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen not found. Installing..."
    brew install xcodegen
fi

# List the contents of the current directory
ls .

# Change to the project directory (assuming one level up is correct)
cd ..

# ALL STEPS AFTER CLONE PROJECT
# Generate the Xcode project using XcodeGen
echo "Generating Xcode project..."
xcodegen generate

# Check if the Xcode project (.xcodeproj) was generated
PROJECT_NAME=$(ls | grep .xcodeproj | head -n 1)
if [ -z "$PROJECT_NAME" ]; then
    echo "No Xcode project found. Exiting."
    exit 1
fi

echo "Found Xcode project: $PROJECT_NAME"
echo "Check file on project.xcworkspace"

# Check if the xcshareddata directory exists and create it if not
echo "Checking xcshareddata..."
if [ ! -d "$PROJECT_NAME/project.xcworkspace/xcshareddata" ]; then
    echo "xcshareddata directory does not exist. Creating..."
    mkdir -p "$PROJECT_NAME/project.xcworkspace/xcshareddata"
fi

ls "$PROJECT_NAME/project.xcworkspace/xcshareddata"

# Check if the swiftpm directory exists and create it if not
echo "Checking swiftpm..."
if [ ! -d "$PROJECT_NAME/project.xcworkspace/xcshareddata/swiftpm" ]; then
    echo "swiftpm directory does not exist. Creating..."
    mkdir -p "$PROJECT_NAME/project.xcworkspace/xcshareddata/swiftpm"
fi

ls "$PROJECT_NAME/project.xcworkspace/xcshareddata/swiftpm"

# Check if Package.resolved exists, if not, create it
echo "Checking Package.resolved..."
PACKAGE_RESOLVED_PATH="$PROJECT_NAME/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
if [ ! -f "$PACKAGE_RESOLVED_PATH" ]; then
    echo "Package.resolved does not exist. Creating..."
    cat <<EOL > "$PACKAGE_RESOLVED_PATH"
{
  "originHash" : "",
  "pins" : [
    {
      "identity" : "",
      "kind" : "",
      "location" : "",
      "state" : {
        "revision" : "",
        "version" : ""
      }
    }
  ],
  "version" : 3
}
EOL
fi

# Resolve package dependencies to generate Package.resolved
echo "Resolving package dependencies..."
xcodebuild -resolvePackageDependencies -project "$PROJECT_NAME" -scheme Impulsum

# Check if Package.resolved was successfully created
if [ -f "$PACKAGE_RESOLVED_PATH" ]; then
    echo "Package.resolved generated successfully."
else
    echo "Failed to generate Package.resolved."
    exit 1
fi
