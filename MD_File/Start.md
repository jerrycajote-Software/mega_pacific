PS C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific> flutter create frontend

┌─────────────────────────────────────────────────────────┐
│ A new version of Flutter is available!                  │
│                                                         │
│ To update to the latest version, run "flutter upgrade". │
└─────────────────────────────────────────────────────────┘
Creating project frontend...
Resolving dependencies in `frontend`... (1.7s)
Downloading packages... 
Got dependencies in `frontend`.
Wrote 129 files.

All done!
You can find general documentation for Flutter at: https://docs.flutter.dev/
Detailed API documentation is available at: https://api.flutter.dev/
If you prefer video documentation, consider: https://www.youtube.com/c/flutterdev

In order to run your application, type:

  $ cd frontend
  $ flutter run

Your application code is in frontend\lib\main.dart.

The configured version of Java detected may conflict with the Gradle version in your new Flutter app.

[RECOMMENDED] If so, to keep the default Gradle version 8.3, make
sure to download a compatible Java version
(Java 17 <= compatible Java version < Java 21).
You may configure this compatible Java version by running:
`flutter config --jdk-dir=<JDK_DIRECTORY>`
Note that this is a global configuration for Flutter.


Alternatively, to continue using your configured Java version, update the Gradle
version specified in the following file to a compatible Gradle version (compatible Gradle version range: 8.4 - 8.7):
C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific\frontend\android/gradle/wrapper/gradle-wrapper.properties

You may also update the Gradle version used by running
`./gradlew wrapper --gradle-version=<COMPATIBLE_GRADLE_VERSION>`.

See
https://docs.gradle.org/current/userguide/compatibility.html#java for details
on compatible Java/Gradle versions, and see
https://docs.gradle.org/current/userguide/gradle_wrapper.html#sec:upgrading_wrapper
for more details on using the Gradle Wrapper command to update the Gradle version
used.

# backend

PS C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific> cd backend
PS C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific\backend> npm install

up to date, audited 82 packages in 2s

23 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
PS C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific\backend>
                                                               npm fund
backend@1.0.0
└─┬ https://opencollective.com/express
  │ └── body-parser@2.2.2, http-errors@2.0.1, iconv-lite@0.7.2, mime-types@3.0.2, cors@2.8.6, express@5.2.1, content-disposition@1.0.1, finalhandler@2.1.1, send@1.2.1, serve-static@2.2.1, path-to-regexp@8.4.2
  └── https://github.com/sponsors/ljharb
      └── qs@6.15.0, side-channel@1.1.0, object-inspect@1.13.4, side-channel-list@1.0.0, side-channel-map@1.0.1, call-bound@1.0.4, function-bind@1.1.2, get-intrinsic@1.3.0, gopd@1.2.0, has-symbols@1.1.0, side-channel-weakmap@1.0.2

PS C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific\backend> 



# backend
PS C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific> cd backend
PS C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific\backend> npm init -y
Wrote to C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific\backend\package.json:

{
  "name": "backend",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "type": "commonjs"
}


PS C:\Users\Jerry Cajote\Documents\Vcode\mega_pacific\backend> npm install express cors body-parser pg

added 81 packages, and audited 82 packages in 5s

23 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities


