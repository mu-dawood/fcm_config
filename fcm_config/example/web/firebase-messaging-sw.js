importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyAvbTwKTK7achLEiAE81gL2I3PfaG331QI",
    authDomain: "fcmconfig-d7f91.firebaseapp.com",
    projectId: "fcmconfig-d7f91",
    storageBucket: "fcmconfig-d7f91.appspot.com",
    messagingSenderId: "590619822303",
    appId: "1:590619822303:web:2ee20c7ac37e8d624d816a",
    measurementId: "G-W1ZSZGYNCW"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});