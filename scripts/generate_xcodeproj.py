#!/usr/bin/env python3
"""Generate Mothlight.xcodeproj for opening in Xcode on macOS."""
import hashlib
import os

ROOT = os.path.join(os.path.dirname(__file__), "..", "Mothlight")
PROJ_DIR = os.path.join(ROOT, "Mothlight.xcodeproj")
TARGET = "Mothlight"
BUNDLE_ID = "com.poulsbo.mothlight"


def uid(seed: str) -> str:
    return hashlib.md5(seed.encode()).hexdigest()[:24].upper()


def collect_swift_files():
    files = []
    base = os.path.join(ROOT, "Mothlight")
    for dirpath, _, filenames in os.walk(base):
        for name in sorted(filenames):
            if name.endswith(".swift"):
                abs_path = os.path.join(dirpath, name)
                rel = os.path.relpath(abs_path, ROOT).replace("\\", "/")
                files.append(rel)
    return files


SWIFT_FILES = collect_swift_files()
RESOURCES = [
    ("Mothlight/Assets.xcassets", "folder.assetcatalog"),
    ("Mothlight/LaunchScreen.storyboard", "file.storyboard"),
    ("Mothlight/PrivacyInfo.xcprivacy", "text.xml"),
]
STOREKIT = "Configuration/Products.storekit"

PROJ_ID = uid("project")
TARGET_ID = uid("target")
SOURCES_PHASE = uid("sources")
RESOURCES_PHASE = uid("resources")
FRAMEWORKS_PHASE = uid("frameworks")
PRODUCT_REF = uid("product")
MAIN_GROUP = uid("maingroup")
MOTH_GROUP = uid("mothgroup")
CONFIG_GROUP = uid("configgroup")
PRODUCTS_GROUP = uid("productsgroup")
PACKAGE_REF = uid("package-google")
PACKAGE_PRODUCT = uid("product-google")
TARGET_CONFIG = uid("target-config-list")
PROJECT_CONFIG = uid("project-config-list")
DEBUG_PROJ = uid("debug-project")
RELEASE_PROJ = uid("release-project")
DEBUG_TGT = uid("debug-target")
RELEASE_TGT = uid("release-target")
BUILD_GMA = uid("build-gma")

file_refs = {p: uid("ref-" + p) for p in SWIFT_FILES + [r[0] for r in RESOURCES] + [STOREKIT]}
build_files = {p: uid("build-" + p) for p in SWIFT_FILES + [r[0] for r in RESOURCES]}
build_files[STOREKIT] = uid("build-storekit")  # not in resources phase

build_file_lines = []
for p in SWIFT_FILES:
    base = os.path.basename(p)
    build_file_lines.append(
        f"\t\t{build_files[p]} /* {base} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[p]} /* {base} */; }};"
    )
for path, _ in RESOURCES:
    base = os.path.basename(path)
    build_file_lines.append(
        f"\t\t{build_files[path]} /* {base} in Resources */ = {{isa = PBXBuildFile; fileRef = {file_refs[path]} /* {base} */; }};"
    )
build_file_lines.append(
    f"\t\t{BUILD_GMA} /* GoogleMobileAds in Frameworks */ = {{isa = PBXBuildFile; productRef = {PACKAGE_PRODUCT} /* GoogleMobileAds */; }};"
)

file_ref_lines = []
for p in SWIFT_FILES:
    rel = p[len("Mothlight/") :] if p.startswith("Mothlight/") else p
    base = os.path.basename(p)
    file_ref_lines.append(
        f'\t\t{file_refs[p]} /* {base} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{rel}"; sourceTree = "<group>"; }};'
    )
for path, ftype in RESOURCES:
    base = os.path.basename(path)
    rel = path[len("Mothlight/") :] if path.startswith("Mothlight/") else path
    file_ref_lines.append(
        f'\t\t{file_refs[path]} /* {base} */ = {{isa = PBXFileReference; lastKnownFileType = {ftype}; path = "{rel}"; sourceTree = "<group>"; }};'
    )
file_ref_lines.append(
    f'\t\t{file_refs[STOREKIT]} /* Products.storekit */ = {{isa = PBXFileReference; lastKnownFileType = text; path = Products.storekit; sourceTree = "<group>"; }};'
)
file_ref_lines.append(
    f'\t\t{PRODUCT_REF} /* {TARGET}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {TARGET}.app; sourceTree = BUILT_PRODUCTS_DIR; }};'
)

moth_children = [f"{file_refs[p]} /* {os.path.basename(p)} */," for p in SWIFT_FILES]
moth_children += [f"{file_refs[path]} /* {os.path.basename(path)} */," for path, _ in RESOURCES]

pbxproj = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_file_lines)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(file_ref_lines)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{FRAMEWORKS_PHASE} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{BUILD_GMA} /* GoogleMobileAds in Frameworks */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{PRODUCTS_GROUP} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{PRODUCT_REF} /* {TARGET}.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{CONFIG_GROUP} /* Configuration */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{file_refs[STOREKIT]} /* Products.storekit */,
\t\t\t);
\t\t\tpath = Configuration;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{MOTH_GROUP} /* Mothlight */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{chr(10).join("\t\t\t\t" + c for c in moth_children)}
\t\t\t);
\t\t\tpath = Mothlight;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{MAIN_GROUP} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{MOTH_GROUP} /* Mothlight */,
\t\t\t\t{CONFIG_GROUP} /* Configuration */,
\t\t\t\t{PRODUCTS_GROUP} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{TARGET_ID} /* {TARGET} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {TARGET_CONFIG} /* Build configuration list for PBXNativeTarget "{TARGET}" */;
\t\t\tbuildPhases = (
\t\t\t\t{SOURCES_PHASE} /* Sources */,
\t\t\t\t{FRAMEWORKS_PHASE} /* Frameworks */,
\t\t\t\t{RESOURCES_PHASE} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = {TARGET};
\t\t\tpackageProductDependencies = (
\t\t\t\t{PACKAGE_PRODUCT} /* GoogleMobileAds */,
\t\t\t);
\t\t\tproductName = {TARGET};
\t\t\tproductReference = {PRODUCT_REF} /* {TARGET}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{PROJ_ID} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{TARGET_ID} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {PROJECT_CONFIG} /* Build configuration list for PBXProject "Mothlight" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {MAIN_GROUP};
\t\t\tpackageReferences = (
\t\t\t\t{PACKAGE_REF} /* XCRemoteSwiftPackageReference "swift-package-manager-google-mobile-ads" */,
\t\t\t);
\t\t\tproductRefGroup = {PRODUCTS_GROUP} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{TARGET_ID} /* {TARGET} */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{RESOURCES_PHASE} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(f"\t\t\t\t{build_files[path]} /* {os.path.basename(path)} in Resources */," for path, _ in RESOURCES)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{SOURCES_PHASE} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(f"\t\t\t\t{build_files[p]} /* {os.path.basename(p)} in Sources */," for p in SWIFT_FILES)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{DEBUG_PROJ} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{RELEASE_PROJ} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{DEBUG_TGT} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Mothlight/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tOTHER_LDFLAGS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"-ObjC",
\t\t\t\t);
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSUPPORTS_MACCATALYST = NO;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{RELEASE_TGT} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Mothlight/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tOTHER_LDFLAGS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"-ObjC",
\t\t\t\t);
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSUPPORTS_MACCATALYST = NO;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{PROJECT_CONFIG} /* Build configuration list for PBXProject "Mothlight" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{DEBUG_PROJ} /* Debug */,
\t\t\t\t{RELEASE_PROJ} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{TARGET_CONFIG} /* Build configuration list for PBXNativeTarget "Mothlight" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{DEBUG_TGT} /* Debug */,
\t\t\t\t{RELEASE_TGT} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */

/* Begin XCRemoteSwiftPackageReference section */
\t\t{PACKAGE_REF} /* XCRemoteSwiftPackageReference "swift-package-manager-google-mobile-ads" */ = {{
\t\t\tisa = XCRemoteSwiftPackageReference;
\t\t\trepositoryURL = "https://github.com/googleads/swift-package-manager-google-mobile-ads";
\t\t\trequirement = {{
\t\t\t\tkind = upToNextMajorVersion;
\t\t\t\tminimumVersion = 11.0.0;
\t\t\t}};
\t\t}};
/* End XCRemoteSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
\t\t{PACKAGE_PRODUCT} /* GoogleMobileAds */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {PACKAGE_REF} /* XCRemoteSwiftPackageReference "swift-package-manager-google-mobile-ads" */;
\t\t\tproductName = GoogleMobileAds;
\t\t}};
/* End XCSwiftPackageProductDependency section */

\t}};
\trootObject = {PROJ_ID} /* Project object */;
}}
"""

scheme = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{TARGET_ID}"
               BuildableName = "{TARGET}.app"
               BlueprintName = "{TARGET}"
               ReferencedContainer = "container:Mothlight.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{TARGET_ID}"
            BuildableName = "{TARGET}.app"
            BlueprintName = "{TARGET}"
            ReferencedContainer = "container:Mothlight.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
      <StoreKitConfigurationFileReference
         identifier = "../Configuration/Products.storekit">
      </StoreKitConfigurationFileReference>
   </LaunchAction>
</Scheme>
"""

os.makedirs(PROJ_DIR, exist_ok=True)
os.makedirs(os.path.join(PROJ_DIR, "xcshareddata", "xcschemes"), exist_ok=True)
with open(os.path.join(PROJ_DIR, "project.pbxproj"), "w", encoding="utf-8") as f:
    f.write(pbxproj)
with open(os.path.join(PROJ_DIR, "xcshareddata", "xcschemes", "Mothlight.xcscheme"), "w", encoding="utf-8") as f:
    f.write(scheme)
print("Wrote", PROJ_DIR, "with", len(SWIFT_FILES), "Swift files")
