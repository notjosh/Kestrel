fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## Mac
### mac test
```
fastlane mac test
```
Runs all the tests
### mac release
```
fastlane mac release
```
Publishes a new build
### mac build
```
fastlane mac build
```
Makes a build
### mac dmg
```
fastlane mac dmg
```
Assembles a new .dmg
### mac sparkle
```
fastlane mac sparkle
```
Assembles a new Sparkle build
### mac verify
```
fastlane mac verify
```
Verify signing, etc
### mac dist
```
fastlane mac dist
```
Distributes build (to S3)

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
