const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { PubSub } = require("@google-cloud/pubsub");

admin.initializeApp();
const pubsub = new PubSub();

exports.validateMove = functions.database
  .ref("/game/grid/{cellKey}")
  .onWrite(async (change, context) => {
    const cellKey = context.params.cellKey;
    const playerId = change.after.val();

    const isConnected = change.after.exists();

    await admin
      .database()
      .ref(`/game/ready/${playerId}`)
      .set(isConnected ? false : null); 

    if (!playerId) return null;

    // Validación de movimiento
    const snapshot = await admin
      .database()
      .ref(`/game/players/${playerId}`)
      .get();
    const playerData = snapshot.val();

    if (!playerData) return null;

    // Publicar en Pub/Sub
    const topic = pubsub.topic("game-updates");
    await topic.publishJSON({ playerId, cellKey });

    return null;
  });
