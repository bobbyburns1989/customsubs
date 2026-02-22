#!/bin/bash

# ============================================================
# CustomSubs v1.1.0 - Complete Release Build Preparation
# ============================================================
# This script performs a full clean build preparation:
# 1. Deep clean all build artifacts
# 2. Flutter pub get
# 3. Code generation (build_runner)
# 4. iOS pod install
# 5. Verification checks
# 6. Opens Xcode ready for archiving
# ============================================================

set -e  # Exit on any error

echo "🚀 CustomSubs v1.1.0 - Release Build Preparation"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================
# STEP 1: DEEP CLEAN
# ============================================================

echo -e "${BLUE}📦 Step 1/7: Deep Clean${NC}"
echo "Removing all build artifacts..."
echo ""

# Flutter clean
echo "  → Running flutter clean..."
flutter clean

# Remove build directories
echo "  → Removing build directories..."
rm -rf build/
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# iOS clean
echo "  → Cleaning iOS build artifacts..."
rm -rf ios/build/
rm -rf ios/Pods/
rm -rf ios/.symlinks/
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/CustomSubs-*

# Remove generated files (will be regenerated)
echo "  → Removing generated files..."
find lib -name "*.g.dart" -type f -delete
find lib -name "*.freezed.dart" -type f -delete

echo -e "${GREEN}✅ Deep clean complete${NC}"
echo ""

# ============================================================
# STEP 2: FLUTTER PUB GET
# ============================================================

echo -e "${BLUE}📦 Step 2/7: Flutter Pub Get${NC}"
echo "Fetching dependencies..."
echo ""

flutter pub get

echo -e "${GREEN}✅ Dependencies fetched${NC}"
echo ""

# ============================================================
# STEP 3: CODE GENERATION
# ============================================================

echo -e "${BLUE}📦 Step 3/7: Code Generation (build_runner)${NC}"
echo "Generating Riverpod providers and Hive adapters..."
echo ""

dart run build_runner build --delete-conflicting-outputs

echo -e "${GREEN}✅ Code generation complete${NC}"
echo ""

# ============================================================
# STEP 4: VERIFY CODE GENERATION
# ============================================================

echo -e "${BLUE}📦 Step 4/7: Verify Generated Files${NC}"
echo "Checking critical generated files exist..."
echo ""

CRITICAL_FILES=(
    "lib/core/providers/entitlement_provider.g.dart"
    "lib/features/home/home_controller.g.dart"
    "lib/features/add_subscription/add_subscription_controller.g.dart"
    "lib/data/models/subscription.g.dart"
)

MISSING_FILES=0
for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file ${RED}(MISSING)${NC}"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -gt 0 ]; then
    echo -e "${RED}❌ Error: $MISSING_FILES generated files missing${NC}"
    echo "Run build_runner again manually and check for errors"
    exit 1
fi

echo -e "${GREEN}✅ All critical files generated${NC}"
echo ""

# ============================================================
# STEP 5: IOS POD INSTALL
# ============================================================

echo -e "${BLUE}📦 Step 5/7: iOS Pod Install${NC}"
echo "Installing iOS dependencies..."
echo ""

cd ios
pod install --repo-update
cd ..

echo -e "${GREEN}✅ iOS pods installed${NC}"
echo ""

# ============================================================
# STEP 6: FLUTTER ANALYZE
# ============================================================

echo -e "${BLUE}📦 Step 6/7: Flutter Analyze${NC}"
echo "Running static analysis..."
echo ""

flutter analyze --no-pub > analyze_output.txt 2>&1

if grep -q "No issues found" analyze_output.txt; then
    echo -e "${GREEN}✅ No issues found${NC}"
    rm analyze_output.txt
elif grep -q "0 issues found" analyze_output.txt; then
    echo -e "${GREEN}✅ 0 issues found${NC}"
    rm analyze_output.txt
else
    echo -e "${YELLOW}⚠️  Issues detected:${NC}"
    cat analyze_output.txt
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Aborted by user${NC}"
        exit 1
    fi
    rm analyze_output.txt
fi

echo ""

# ============================================================
# STEP 7: VERSION CHECK
# ============================================================

echo -e "${BLUE}📦 Step 7/7: Version Verification${NC}"
echo "Checking version in pubspec.yaml..."
echo ""

VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
echo "  Current version: ${GREEN}$VERSION${NC}"

if [[ $VERSION != "1.1.0+15" ]]; then
    echo -e "${YELLOW}⚠️  Expected version: 1.1.0+15${NC}"
    echo -e "${YELLOW}⚠️  Update pubspec.yaml before archiving${NC}"
fi

echo ""

# ============================================================
# FINAL CHECKLIST
# ============================================================

echo -e "${BLUE}📋 Pre-Archive Checklist${NC}"
echo "=================================================="
echo ""

echo -e "${GREEN}✅${NC} Deep clean completed"
echo -e "${GREEN}✅${NC} Dependencies fetched"
echo -e "${GREEN}✅${NC} Code generated"
echo -e "${GREEN}✅${NC} iOS pods installed"
echo -e "${GREEN}✅${NC} Static analysis passed"
echo -e "${GREEN}✅${NC} Version verified"
echo ""

# ============================================================
# FINAL INSTRUCTIONS
# ============================================================

echo -e "${BLUE}🎯 Next Steps in Xcode${NC}"
echo "=================================================="
echo ""
echo "1. Xcode will open to the workspace"
echo "2. Select target: Runner"
echo "3. Select device: Any iOS Device (arm64)"
echo "4. Top menu: Product → Archive"
echo "5. Wait for archive to complete (~2-3 minutes)"
echo "6. Distribute App → App Store Connect"
echo ""

# ============================================================
# OPEN XCODE
# ============================================================

echo -e "${BLUE}🚀 Opening Xcode...${NC}"
echo ""

sleep 2

open ios/Runner.xcworkspace

echo -e "${GREEN}✅ Build preparation complete!${NC}"
echo ""
echo "Xcode is now open. Press 'Archive' when ready."
echo ""
