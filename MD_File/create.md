
step 1: mkdir main folder
step2: c, sub-f front,back,3d,Database

before run front, run 

Make sure:

Emulator is running OR
Chrome browser is enabled (for web)

cmd:
flutter config --enable-web
flutter devices

run through browser chrome
flutter run -d chrome

step 4 back-end
mkdir backend
cd backend
npm init -y

Install dependencies:

npm install express cors body-parser pg


3. -- Setup Backend --

cd backend
npm install
node server.js


-- Setup Database --
 PostgreSQL
Create database: roofing_db
Import tables

4. Setup Frontend

cd frontend
flutter pub get
flutter run

5. Run 3D Module

Open 3d-module/index.html in browser