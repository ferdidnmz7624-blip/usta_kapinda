const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const { setGlobalOptions } = require("firebase-functions/v2");
const nodemailer = require("nodemailer");
const { defineSecret } = require("firebase-functions/params");
const { google } = require("googleapis");
const EMAIL_PASSWORD = defineSecret("EMAIL_PASSWORD");

function generateVerificationCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

admin.initializeApp();

setGlobalOptions({
  region: "europe-west1",
  maxInstances: 10,
});

// TEST FONKSİYONU
exports.test = onRequest((req, res) => {
  logger.info("TEST ÇALIŞTI");
  res.send("OK");
});

// MESAJ BİLDİRİMİ
exports.sendMessageNotification = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    try {
      logger.info("FUNCTION BAŞLADI");

      if (!event.data) {
        logger.error("event.data boş");
        return;
      }

      const message = event.data.data();

      logger.info("MESSAGE:", message);

      const receiverId = message.receiverId;

      logger.info("RECEIVER:", receiverId);

      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(receiverId)
        .get();

      logger.info("USER EXISTS:", userDoc.exists);

      if (!userDoc.exists) return;

const user = userDoc.data();

if (user.isFrozen || user.isDeleting) {
  logger.info("Kullanıcı pasif. Bildirim gönderilmeyecek.");
  return;
}

const token = user.fcmToken;

logger.info("TOKEN:", token);

if (!token) return;

      logger.info("TOKEN:", token);

      if (!token) return;

      const response = await admin.messaging().send({
        token: token,
        notification: {
          title: "Yeni Mesaj",
          body: message.message,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "messages",
            sound: "default",
          },
        },
      });

      logger.info("SEND OK:", response);
    } catch (e) {
      logger.error("HATA:", e);
    }
  }
);
// YENİ TEKLİF BİLDİRİMİ
exports.sendOfferNotification = onDocumentCreated(
  "offers/{offerId}",
  async (event) => {
    try {
      logger.info("YENİ TEKLİF");

      if (!event.data) return;

      const offer = event.data.data();

      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(offer.customerId)
        .get();

      if (!userDoc.exists) return;

const user = userDoc.data();

if (user.isFrozen || user.isDeleting) {
  logger.info("Kullanıcı pasif. Bildirim gönderilmeyecek.");
  return;
}

const token = user.fcmToken;

if (!token) return;

      const response = await admin.messaging().send({
        token: token,
        notification: {
          title: "📩 İlanınıza Yeni Teklif Geldi",
          body: `${offer.jobTitle} ilanı için ₺${offer.price} teklif verildi.`,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "messages",
            sound: "default",
          },
        },
      });

      logger.info("OFFER SEND OK:", response);

    } catch (e) {
      logger.error(e);
    }
  }
);
// TEKLİF KABUL / RED BİLDİRİMİ
exports.sendOfferStatusNotification = onDocumentUpdated(
  "offers/{offerId}",
  async (event) => {
    try {
      const before = event.data.before.data();
      const after = event.data.after.data();

      if (!before || !after) return;

      // Status değişmediyse çık
      if (before.status === after.status) return;

      if (
        after.status !== "accepted" &&
        after.status !== "rejected"
      ) {
        return;
      }

      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(after.craftsmanId)
        .get();

      if (!userDoc.exists) return;

const user = userDoc.data();

if (user.isFrozen || user.isDeleting) {
  logger.info("Kullanıcı pasif. Bildirim gönderilmeyecek.");
  return;
}

const token = user.fcmToken;

if (!token) return;

      const title =
        after.status === "accepted"
          ? "🎉 Teklifiniz Kabul Edildi"
          : "❌ Teklifiniz Reddedildi";

      const body =
        after.status === "accepted"
          ? "Müşteri teklifinizi kabul etti. Artık iletişime geçebilirsiniz."
          : "Maalesef teklifiniz reddedildi.";

      const response = await admin.messaging().send({
        token,
        notification: {
          title,
          body,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "messages",
            sound: "default",
          },
        },
      });

      logger.info("STATUS SEND OK:", response);

    } catch (e) {
      logger.error(e);
    }
  }
);
// FAVORİYE EKLENDİ BİLDİRİMİ
exports.sendFavoriteNotification = onDocumentCreated(
  "users/{currentUserId}/favorites/{favoriteUserId}",
  async (event) => {
    try {
      if (!event.data) return;

      const { currentUserId, favoriteUserId } = event.params;

      const favoriteUser = await admin
        .firestore()
        .collection("users")
        .doc(favoriteUserId)
        .get();

      if (!favoriteUser.exists) return;

      const currentUser = await admin
        .firestore()
        .collection("users")
        .doc(currentUserId)
        .get();

      if (!currentUser.exists) return;

const user = favoriteUser.data();

if (user.isFrozen || user.isDeleting) {
  logger.info("Kullanıcı pasif. Bildirim gönderilmeyecek.");
  return;
}

const token = user.fcmToken;

if (!token) return;

      const firstName = currentUser.data().firstName ?? "";
      const lastName = currentUser.data().lastName ?? "";

      const first =
        firstName.length > 0
          ? firstName[0] + "*".repeat(Math.max(0, firstName.length - 1))
          : "";

      const last =
        lastName.length > 0
          ? lastName[0] + "*".repeat(Math.max(0, lastName.length - 1))
          : "";

      await admin.messaging().send({
        token,
        notification: {
          title: "⭐ Favorilere Eklendiniz",
          body: `${first} ${last} sizi favorilerine ekledi.`,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "messages",
            sound: "default",
          },
        },
      });

      logger.info("FAVORITE SEND OK");

    } catch (e) {
      logger.error("FAVORITE ERROR:", e);
    }
  }
);
// DEĞERLENDİRME BİLDİRİMİ
exports.sendReviewNotification = onDocumentCreated(
  "reviews/{reviewId}",
  async (event) => {
    try {
      if (!event.data) return;

      const review = event.data.data();

      const targetUserId =
        review.reviewerType === "customer"
          ? review.craftsmanId
          : review.customerId;

      const reviewerId =
        review.reviewerType === "customer"
          ? review.customerId
          : review.craftsmanId;

      const targetUser = await admin
        .firestore()
        .collection("users")
        .doc(targetUserId)
        .get();

      if (!targetUser.exists) return;

      const reviewer = await admin
        .firestore()
        .collection("users")
        .doc(reviewerId)
        .get();

      if (!reviewer.exists) return;

const user = targetUser.data();

if (user.isFrozen || user.isDeleting) {
  logger.info("Kullanıcı pasif. Bildirim gönderilmeyecek.");
  return;
}

const token = user.fcmToken;

if (!token) return;

      const firstName = reviewer.data().firstName ?? "";
      const lastName = reviewer.data().lastName ?? "";

      const first =
        firstName.length > 0
          ? firstName[0] + "*".repeat(Math.max(0, firstName.length - 1))
          : "";

      const last =
        lastName.length > 0
          ? lastName[0] + "*".repeat(Math.max(0, lastName.length - 1))
          : "";

      const response = await admin.messaging().send({
        token,
        notification: {
          title: "🌟 Yeni Değerlendirme",
          body: `${first} ${last} sizi değerlendirdi.`,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "messages",
            sound: "default",
          },
        },
      });

      logger.info("REVIEW SEND OK:", response);

    } catch (e) {
      logger.error("REVIEW ERROR:", e);
    }
  }
);

// YENİ İŞ FIRSATI BİLDİRİMİ
exports.sendNewJobNotification = onDocumentCreated(
  "jobs/{jobId}",
  async (event) => {
    try {
      if (!event.data) {
        logger.error("JOB DATA YOK");
        return;
      }

      const job = event.data.data();

      logger.info("YENİ İLAN:", job);

      if (job.status !== "active") {
        logger.info("İlan aktif değil.");
        return;
      }

      const snapshot = await admin
        .firestore()
        .collection("users")
        .where("accountType", "==", "craftsman")
        .get();

      logger.info("Bulunan usta:", snapshot.size);

      for (const doc of snapshot.docs) {
        const user = doc.data();
if (user.isFrozen || user.isDeleting) {
  logger.info("Kullanıcı pasif.");
  continue;
}
        logger.info("------------------------");
        logger.info("Usta UID:", doc.id);
        logger.info("Şehir:", user.city);
        logger.info("Meslekler:", user.professions);
        logger.info("Token:", user.fcmToken);

        if (!user.fcmToken) {
          logger.info("TOKEN YOK");
          continue;
        }

        if (
          (user.city ?? "").trim().toLowerCase() !==
          (job.city ?? "").trim().toLowerCase()
        ) {
          logger.info("ŞEHİR EŞLEŞMEDİ");
          continue;
        }

        const professions = Array.isArray(user.professions)
            ? user.professions
            : [];

        const hasProfession = professions.some((p) =>
          String(p).trim().toLowerCase() ===
          String(job.category).trim().toLowerCase()
        );

        if (!hasProfession) {
          logger.info("MESLEK EŞLEŞMEDİ");
          continue;
        }

        logger.info("BİLDİRİM GÖNDERİLİYOR");

        const response = await admin.messaging().send({
          token: user.fcmToken,
          notification: {
            title: "🔥 Size Uygun Yeni İş Fırsatı",
            body:
              `${job.city} / ${job.district} bölgesinde "${job.title}" ilanı yayınlandı.`,
          },
          android: {
            priority: "high",
            notification: {
              channelId: "messages",
              sound: "default",
            },
          },
        });

        logger.info("GÖNDERİLDİ:", response);
      }

      logger.info("FONKSİYON TAMAMLANDI");

    } catch (e) {
      logger.error("HATA:", e);
    }
  }
);
exports.sendSupportReplyEmail = onDocumentUpdated(
  {
document: "support_requests/{requestId}",
    secrets: [EMAIL_PASSWORD],
  },
  async (event) => {
    try {
      const before = event.data.before.data();
      const after = event.data.after.data();

      if (!before || !after) return;

      // Cevap değişmediyse çık
      if (before.adminReply === after.adminReply) return;

      // Boş cevap gönderme
      if (!after.adminReply || after.adminReply.trim() === "") return;
      const transporter = nodemailer.createTransport({
        host: "ustakapinda.org",
        port: 465,
        secure: true,
        auth: {
          user: "support@ustakapinda.org",
          pass: EMAIL_PASSWORD.value(),
        },
      });

      await transporter.sendMail({
        from: '"Usta Kapında Destek" <support@ustakapinda.org>',
        to: after.email,
        subject: `Destek Talebiniz Yanıtlandı (${after.ticketNo})`,
        html: `
          <h2>Merhaba ${after.firstName},</h2>

          <p>Destek talebinize cevap verildi.</p>

          <hr>

          <b>Konu:</b> ${after.subject}<br>
          <b>Talep No:</b> ${after.ticketNo}

          <br><br>

          <b>Destek Ekibi Cevabı:</b>

          <p>${after.adminReply}</p>

          <br>

          <hr>

          <p>Bu e-posta otomatik olarak gönderilmiştir.</p>

          <b>Usta Kapında Destek Ekibi</b>
        `,
      });

      logger.info("DESTEK MAİLİ GÖNDERİLDİ");
    } catch (e) {
      logger.error("DESTEK MAİL HATASI:", e);
    }
  }
);
// YENİ DESTEK TALEBİ BİLDİRİMİ
exports.sendNewSupportRequestEmail = onDocumentCreated(
  {
    document: "support_requests/{requestId}",
    secrets: [EMAIL_PASSWORD],
  },
  async (event) => {
    try {
      if (!event.data) {
        logger.error("DESTEK TALEBİ DATA YOK");
        return;
      }

      const support = event.data.data();

      logger.info("YENİ DESTEK TALEBİ:", support);

      const transporter = nodemailer.createTransport({
        host: "ustakapinda.org",
        port: 465,
        secure: true,
        auth: {
          user: "support@ustakapinda.org",
          pass: EMAIL_PASSWORD.value(),
        },
      });

      // -----------------------------------
      // 1. SANA BİLDİRİM E-POSTASI
      // -----------------------------------

      await transporter.sendMail({
        from: '"Usta Kapında Destek" <support@ustakapinda.org>',
        to: "support@ustakapinda.org",
        subject: `🔔 Yeni Destek Talebi - ${support.ticketNo ?? ""}`,
        html: `
          <div style="font-family: Arial, sans-serif; line-height: 1.6;">

            <h2 style="color:#1b5e20;">
              Yeni Destek Talebi
            </h2>

            <hr>

            <p>
              <b>Talep No:</b>
              ${support.ticketNo ?? "-"}
            </p>

            <p>
              <b>Ad Soyad:</b>
              ${support.firstName ?? ""} ${support.lastName ?? ""}
            </p>

            <p>
              <b>E-posta:</b>
              ${support.email ?? "-"}
            </p>

            <p>
              <b>Konu:</b>
              ${support.subject ?? "-"}
            </p>

            <p>
              <b>Durum:</b>
              ${support.status ?? "open"}
            </p>

            <hr>

            <h3>Destek Talebi</h3>

            <p>
              ${support.description ?? ""}
            </p>

            ${
              support.imageUrl
                ? `
                  <p>
                    <b>Ekran Görüntüsü:</b>
                  </p>
                  <p>
                    <a href="${support.imageUrl}" target="_blank">
                      Ekran görüntüsünü görüntüle
                    </a>
                  </p>
                `
                : ""
            }

            <hr>

            <p>
              Bu e-posta Usta Kapında destek sistemi tarafından
              otomatik olarak gönderilmiştir.
            </p>

            <b>Usta Kapında Destek Ekibi</b>

          </div>
        `,
      });

      logger.info("YENİ DESTEK TALEBİ BİLDİRİMİ GÖNDERİLDİ");

      // -----------------------------------
      // 2. KULLANICIYA OTOMATİK CEVAP
      // -----------------------------------

      if (support.email) {
        await transporter.sendMail({
          from: '"Usta Kapında Destek" <support@ustakapinda.org>',
          to: support.email,
          subject: `Destek Talebiniz Alındı - ${support.ticketNo ?? ""}`,
          html: `
            <div style="font-family: Arial, sans-serif; line-height: 1.6;">

              <h2>Merhaba ${support.firstName ?? ""},</h2>

              <p>
                Destek talebiniz başarıyla alınmıştır.
              </p>

              <p>
                Talebiniz Usta Kapında Destek Ekibi'ne
                iletilmiştir ve en kısa sürede incelenecektir.
              </p>

              <p>
                İnceleme tamamlandığında tarafınıza
                e-posta yoluyla bilgilendirme yapılacaktır.
              </p>

              <hr>

              <p>
                <b>Talep No:</b>
                ${support.ticketNo ?? "-"}
              </p>

              <p>
                <b>Konu:</b>
                ${support.subject ?? "-"}
              </p>

              <hr>

              <p>
                Aynı konu hakkında tekrar tekrar e-posta
                göndermenize gerek yoktur. Talebiniz kayıt
                altına alınmıştır.
              </p>

              <br>

              <b>Usta Kapında Destek Ekibi</b>

              <br>

              <a href="mailto:support@ustakapinda.org">
                support@ustakapinda.org
              </a>

            </div>
          `,
        });

        logger.info(
          `KULLANICIYA DESTEK ALINDI MAİLİ GÖNDERİLDİ: ${support.email}`
        );
      }

    } catch (e) {
      logger.error("YENİ DESTEK MAİL HATASI:", e);
    }
  }
);
exports.sendVerificationCodeEmail = onRequest(
  { secrets: [EMAIL_PASSWORD] },
  async (req, res) => {
    try {
      const { email } = req.body;

      if (!email) {
        return res.status(400).json({
          success: false,
          message: "E-posta gerekli.",
        });
      }

      const code = generateVerificationCode();

      await admin.firestore().collection("email_verifications").doc(email).set({
        email,
        code,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: Date.now() + 2 * 60 * 1000,
      });

      const transporter = nodemailer.createTransport({
        host: "ustakapinda.org",
        port: 465,
        secure: true,
        auth: {
          user: "support@ustakapinda.org",
          pass: EMAIL_PASSWORD.value(),
        },
      });

      await transporter.sendMail({
        from: '"Usta Kapında" <support@ustakapinda.org>',
        to: email,
        subject: "E-posta Doğrulama Kodu",
        html: `
          <h2>Usta Kapında</h2>
          <p>Doğrulama kodunuz:</p>
          <h1 style="letter-spacing:6px">${code}</h1>
          <p>Bu kod 2 dakika geçerlidir.</p>
        `,
      });

      return res.json({
        success: true,
      });
    } catch (e) {
      logger.error(e);

      return res.status(500).json({
        success: false,
        message: e.toString(),
      });
    }
  }
);
exports.verifyVerificationCode = onRequest(async (req, res) => {
  try {
    const { email, code } = req.body;

    if (!email || !code) {
      return res.status(400).json({
        success: false,
        message: "Eksik bilgi.",
      });
    }

    const doc = await admin
      .firestore()
      .collection("email_verifications")
      .doc(email)
      .get();

    if (!doc.exists) {
      return res.json({
        success: false,
        message: "Kod bulunamadı.",
      });
    }

    const data = doc.data();

    if (Date.now() > data.expiresAt) {
      return res.json({
        success: false,
        expired: true,
      });
    }

    if (data.code !== code) {
      return res.json({
        success: false,
        message: "Kod yanlış.",
      });
    }

    await admin
      .firestore()
      .collection("email_verifications")
      .doc(email)
      .delete();
await admin
  .firestore()
  .collection("verificationCodes")
  .doc(email)
  .delete();
    return res.json({
      success: true,
    });

  } catch (e) {
    logger.error(e);

    return res.status(500).json({
      success: false,
      message: e.toString(),
    });
  }
});
exports.resetPasswordWithCode = onRequest(async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Eksik bilgi.",
      });
    }

    const user = await admin.auth().getUserByEmail(email);

    await admin.auth().updateUser(user.uid, {
      password: password,
    });

    return res.json({
      success: true,
    });
  } catch (e) {
    logger.error(e);

    return res.status(500).json({
      success: false,
      message: e.toString(),
    });
  }
});
exports.deleteExpiredAccounts = onSchedule(
  {
    schedule: "every day 03:00",
    timeZone: "Europe/Istanbul",
  },
  async () => {

    const snapshot = await admin
      .firestore()
      .collection("users")
      .where("isDeleting", "==", true)
      .get();

    const now = new Date();

    for (const doc of snapshot.docs) {

      const data = doc.data();

      if (!data.deleteAt) continue;

      const deleteDate = data.deleteAt.toDate();

      if (deleteDate > now) continue;

const uid = doc.id;

try {


// Kullanıcının ilanlarını sil
const jobs = await admin
    .firestore()
    .collection("jobs")
    .where("userId", "==", uid)
    .get();

for (const job of jobs.docs) {
  await job.ref.delete();
}

// Kullanıcının tekliflerini sil
const offers = await admin
    .firestore()
    .collection("offers")
    .where("craftsmanId", "==", uid)
    .get();

for (const offer of offers.docs) {
  await offer.ref.delete();
}

const customerOffers = await admin
    .firestore()
    .collection("offers")
    .where("customerId", "==", uid)
    .get();

for (const offer of customerOffers.docs) {
  await offer.ref.delete();
}

// Kullanıcının yaptığı değerlendirmeleri sil
const reviews = await admin
    .firestore()
    .collection("reviews")
    .where("reviewerId", "==", uid)
    .get();

for (const review of reviews.docs) {
  await review.ref.delete();
}

// Kullanıcı hakkında yapılan değerlendirmeleri sil
const craftsmanReviews = await admin
    .firestore()
    .collection("reviews")
    .where("craftsmanId", "==", uid)
    .get();

for (const review of craftsmanReviews.docs) {
  await review.ref.delete();
}

const customerReviews = await admin
    .firestore()
    .collection("reviews")
    .where("customerId", "==", uid)
    .get();

for (const review of customerReviews.docs) {
  await review.ref.delete();
}
// Destek taleplerini sil
const supports = await admin
    .firestore()
    .collection("support_requests")
    .where("userId", "==", uid)
    .get();

for (const support of supports.docs) {
  await support.ref.delete();
}
// Favorileri sil
const favorites = await admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("favorites")
    .get();

for (const favorite of favorites.docs) {
  await favorite.ref.delete();
}
// Kullanıcının sohbetlerini sil
const chats = await admin
    .firestore()
    .collection("chats")
    .where("participants", "array-contains", uid)
    .get();

for (const chat of chats.docs) {

  const messages = await chat.ref
      .collection("messages")
      .get();

  for (const message of messages.docs) {
    await message.ref.delete();
  }

  await chat.ref.delete();
  }

  // Kullanıcı belgesini sil
  await admin
      .firestore()
      .collection("users")
      .doc(uid)
      .delete();

  // Authentication hesabını sil
  await admin.auth().deleteUser(uid);

  logger.info(`Kullanıcı tamamen silindi: ${uid}`);

  } catch (e) {
    logger.error(`Silme hatası: ${uid}`, e);
  }
      }
          }
        );
exports.freezeAccount = onCall(async (request) => {

  if (!request.auth) {
    throw new Error("Unauthorized");
  }

  const uid = request.auth.uid;

  await admin.firestore()
      .collection("users")
      .doc(uid)
      .update({
        isFrozen: true,
        isOnline: false,
        lastSeen: admin.firestore.Timestamp.now(),
      });

  return {
    success: true,
  };
});
exports.unfreezeAccount = onCall(async (request) => {

  if (!request.auth) {
    throw new Error("Unauthorized");
  }

  const uid = request.auth.uid;

  await admin.firestore()
      .collection("users")
      .doc(uid)
      .update({
        isFrozen: false,
      });

  return {
    success: true,
  };
});
exports.requestDeleteAccount = onCall(async (request) => {

  if (!request.auth) {
    throw new Error("Unauthorized");
  }

  const uid = request.auth.uid;

  const deleteDate = new Date();
  deleteDate.setDate(deleteDate.getDate() + 14);

  await admin.firestore()
      .collection("users")
      .doc(uid)
      .update({
        isDeleting: true,
        deleteAt: admin.firestore.Timestamp.fromDate(deleteDate),
        isFrozen: true,
        isOnline: false,
        lastSeen: admin.firestore.Timestamp.now(),
      });

  return {
    success: true,
  };
});
exports.cancelDeleteAccount = onCall(async (request) => {

  if (!request.auth) {
    throw new Error("Unauthorized");
  }

  const uid = request.auth.uid;

  await admin.firestore()
      .collection("users")
      .doc(uid)
      .update({
        isDeleting: false,
        deleteAt: null,
        isFrozen: false,
      });

  return {
    success: true,
  };
});
exports.changeAccountType = onCall(async (request) => {

  if (!request.auth) {
    throw new Error("Unauthorized");
  }

  const uid = request.auth.uid;
  const { accountType } = request.data;

  if (!accountType) {
    throw new Error("accountType gerekli.");
  }
const allowedTypes = [
  "customer",
  "craftsman",
];

if (!allowedTypes.includes(accountType)) {
  throw new Error("Geçersiz hesap türü.");
}
  await admin.firestore()
      .collection("users")
      .doc(uid)
      .update({
        accountType: accountType,
      });

  return {
    success: true,
  };
});
exports.changeActiveMode = onCall(async (request) => {

  if (!request.auth) {
    throw new Error("Unauthorized");
  }

  const uid = request.auth.uid;
  const { activeMode } = request.data;

  if (!activeMode) {
    throw new Error("activeMode gerekli.");
  }
const allowedModes = [
  "customer",
  "craftsman",
];

if (!allowedModes.includes(activeMode)) {
  throw new Error("Geçersiz aktif mod.");
}
  await admin.firestore()
      .collection("users")
      .doc(uid)
      .update({
        activeMode: activeMode,
      });

  return {
    success: true,
  };
});
exports.activateCustomerProfile = onCall(async (request) => {

  if (!request.auth) {
    throw new Error("Unauthorized");
  }

  const uid = request.auth.uid;

  await admin.firestore()
      .collection("users")
      .doc(uid)
      .update({
        customerProfile: true,
        activeMode: "customer",
      });

  return {
    success: true,
  };
});
exports.activateCraftsmanProfile = onCall(async (request) => {

  if (!request.auth) {
    throw new Error("Unauthorized");
  }

  const uid = request.auth.uid;

  await admin.firestore()
      .collection("users")
      .doc(uid)
      .update({
        craftsmanProfile: true,
        activeMode: "craftsman",
      });

  return {
    success: true,
  };
});
exports.payOfferWithTokens = onCall(async (request) => {

  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Giriş yapmanız gerekiyor."
    );
  }

  const uid = request.auth.uid;

  const {
    jobId,
    price,
    message,
    estimatedDays,
  } = request.data;

  if (
    !jobId ||
    !price ||
    !message ||
    !estimatedDays
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Eksik bilgi gönderildi."
    );
  }

  const db = admin.firestore();

  const userRef = db.collection("users").doc(uid);

  const jobRef = db.collection("jobs").doc(jobId);

  const offerRef = db.collection("offers").doc();

  await db.runTransaction(async (transaction) => {

    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      throw new HttpsError(
        "not-found",
        "Kullanıcı bulunamadı."
      );
    }

    const jobDoc = await transaction.get(jobRef);

    if (!jobDoc.exists) {
      throw new HttpsError(
        "not-found",
        "İlan bulunamadı."
      );
    }

    const userData = userDoc.data();

    const jobData = jobDoc.data();
    const budget = Number(jobData.budget);

    if (price < 1000) {
      throw new HttpsError(
        "invalid-argument",
        "Minimum teklif tutarı 1000 TL'dir."
      );
    }

    if (price > budget * 1.5) {
      throw new HttpsError(
        "invalid-argument",
        `En fazla ${budget * 1.5} TL teklif verebilirsiniz.`
      );
    }

    if (estimatedDays < 1 || estimatedDays > 100) {
      throw new HttpsError(
        "invalid-argument",
        "Tahmini süre 1 ile 100 gün arasında olmalıdır."
      );
    }

    if (
      message.trim().length < 20 ||
      message.trim().length > 200
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Teklif mesajı 20 ile 200 karakter arasında olmalıdır."
      );
    }
        const currentTokens = userData.tokens ?? 0;

        if (currentTokens < 50) {
          throw new HttpsError(
            "failed-precondition",
            "Teklif verebilmek için en az 50 jeton gereklidir."
          );
        }

        const existingOffer = await db
            .collection("offers")
            .where("jobId", "==", jobId)
            .where("craftsmanId", "==", uid)
            .limit(1)
            .get();

        if (!existingOffer.empty) {
          throw new HttpsError(
            "already-exists",
            "Bu ilana zaten teklif verdiniz."
          );
        }

        transaction.update(userRef, {
          tokens: currentTokens - 50,
        });

        transaction.set(offerRef, {
          id: offerRef.id,
          jobId: jobId,
          jobTitle: jobData.title,
          customerId: jobData.userId,
          craftsmanId: uid,
          price: price,
          message: message,
          estimatedDays: estimatedDays,
          status: "pending",
          customerReviewed: false,
          craftsmanReviewed: false,
          isSeenByCustomer: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

transaction.set(
  db.collection("token_transactions").doc(),
  {
    uid: uid,

    type: "offer_fee",

    amount: -50,

    balanceBefore: currentTokens,

    balanceAfter: currentTokens - 50,

    reason: "Teklif Gönderme",

    referenceId: offerRef.id,

    createdAt:
        admin.firestore.FieldValue.serverTimestamp(),
  }
);
            transaction.set(
              db.collection("notifications").doc(),
              {
                userId: jobData.userId,
                title: "Yeni Teklif",
                body: `${jobData.title} ilanınıza yeni bir teklif gönderildi.`,
                isRead: false,
                createdAt:
                    admin.firestore.FieldValue.serverTimestamp(),
              }
            );

          });

          return {
            success: true,
            message: "Teklif başarıyla gönderildi.",
          };

        });
        exports.acceptOffer = onCall(async (request) => {

          if (!request.auth) {
            throw new Error("Unauthorized");
          }

          const uid = request.auth.uid;
          const { offerId } = request.data;

          if (!offerId) {
            throw new Error("offerId gerekli.");
          }

          const db = admin.firestore();

          const offerRef = db.collection("offers").doc(offerId);

          const offerDoc = await offerRef.get();

          if (!offerDoc.exists) {
            throw new Error("Teklif bulunamadı.");
          }

          const offer = offerDoc.data();

          if (offer.customerId !== uid) {
            throw new Error("Bu teklif size ait değil.");
          }

          await offerRef.update({
            status: "accepted",
          });

          return {
            success: true,
          };
        });
        exports.rejectOffer = onCall(async (request) => {

          if (!request.auth) {
            throw new Error("Unauthorized");
          }

          const uid = request.auth.uid;
          const { offerId } = request.data;

          if (!offerId) {
            throw new Error("offerId gerekli.");
          }

          const db = admin.firestore();

          const offerRef = db.collection("offers").doc(offerId);

          const offerDoc = await offerRef.get();

          if (!offerDoc.exists) {
            throw new Error("Teklif bulunamadı.");
          }

          const offer = offerDoc.data();

          if (offer.customerId !== uid) {
            throw new Error("Bu teklif size ait değil.");
          }

          await offerRef.update({
            status: "rejected",
          });

          return {
            success: true,
          };
        });
        exports.updateJobStatus = onCall(async (request) => {

          if (!request.auth) {
            throw new Error("Unauthorized");
          }

          const uid = request.auth.uid;
          const { jobId, status } = request.data;

          if (!jobId || !status) {
            throw new Error("Eksik parametre.");
          }

          const db = admin.firestore();

          const jobRef = db.collection("jobs").doc(jobId);

          const jobDoc = await jobRef.get();

          if (!jobDoc.exists) {
            throw new Error("İş bulunamadı.");
          }

          const job = jobDoc.data();

          if (job.userId !== uid) {
            throw new Error("Bu ilan size ait değil.");
          }
await jobRef.update({
  status: status,
});

if (
  status === "completed" ||
  status === "cancelled" ||
  status === "closed"
) {
  const chatRef = db.collection("chats").doc(jobId);

  const messages = await chatRef.collection("messages").get();

  for (const message of messages.docs) {
    await message.ref.delete();
  }

  await chatRef.delete();
}

return {
  success: true,
};
        });
        exports.updateOfferStatus = onCall(async (request) => {

          if (!request.auth) {
            throw new Error("Unauthorized");
          }

          const uid = request.auth.uid;
          const { offerId, status } = request.data;
const allowedStatuses = [
  "accepted",
  "rejected",
  "in_progress",
  "completed",
  "reviewed",
  "cancelled",
];

if (!allowedStatuses.includes(status)) {
  throw new Error("Geçersiz durum.");
}
          if (!offerId || !status) {
            throw new Error("Eksik parametre.");
          }

          const db = admin.firestore();

          const offerRef = db.collection("offers").doc(offerId);
          const offerDoc = await offerRef.get();

          if (!offerDoc.exists) {
            throw new Error("Teklif bulunamadı.");
          }

          const offer = offerDoc.data();

          // Sadece müşteri veya teklifi veren usta değiştirebilsin
          if (
            offer.customerId !== uid &&
            offer.craftsmanId !== uid
          ) {
            throw new Error("Yetkiniz yok.");
          }
const currentStatus = offer.status;

const transitions = {
  pending: ["accepted", "rejected"],
  accepted: ["in_progress", "cancelled"],
  in_progress: ["completed", "cancelled"],
  completed: ["reviewed"],
  reviewed: [],
  rejected: [],
  cancelled: [],
};

if (!(transitions[currentStatus] || []).includes(status)) {
  throw new Error("Bu durum değişikliğine izin verilmiyor.");
}
          await offerRef.update({
            status: status,
          });

          return { success: true };
        });
        exports.sendMessage = onCall(async (request) => {

          if (!request.auth) {
            throw new Error("Unauthorized");
          }

          const {
            chatId,
            senderId,
            receiverId,
            message,
          } = request.data;

          if (!chatId || !senderId || !receiverId || !message) {
            throw new Error("Eksik parametre.");
          }

          if (request.auth.uid !== senderId) {
            throw new Error("Yetkiniz yok.");
          }

          const db = admin.firestore();

          const chatRef = db.collection("chats").doc(chatId);

          await chatRef.collection("messages").add({
            senderId,
            receiverId,
            message,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            status: "sent",
          });

          await chatRef.set({
            lastMessage: message,
            lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
            users: [senderId, receiverId],
            unreadCount: {
              [receiverId]: admin.firestore.FieldValue.increment(1),
              [senderId]: 0,
            },
            deletedBy: {},
          }, { merge: true });

          return {
            success: true,
          };

        });
        exports.openChatForOffer = onCall(async (request) => {
          if (!request.auth) {
            throw new Error("Unauthorized");
          }

          const uid = request.auth.uid;
          const { offerId } = request.data;

          if (!offerId) {
            throw new Error("offerId gerekli.");
          }

          const db = admin.firestore();

          const offerRef = db.collection("offers").doc(offerId);
          const offerDoc = await offerRef.get();

          if (!offerDoc.exists) {
            throw new Error("Teklif bulunamadı.");
          }

          const offer = offerDoc.data();

          if (
            offer.customerId !== uid &&
            offer.craftsmanId !== uid
          ) {
            throw new Error("Bu sohbete erişim yetkiniz yok.");
          }

          if (
            offer.status !== "accepted" &&
            offer.status !== "in_progress"
          ) {
            throw new Error("Bu teklif için sohbet açılamaz.");
          }

          const chatRef = db.collection("chats").doc(offer.jobId);

          const chatDoc = await chatRef.get();

          if (!chatDoc.exists) {

            await chatRef.set({
              id: offer.jobId,
              jobId: offer.jobId,
              customerId: offer.customerId,
              craftsmanId: offer.craftsmanId,
              users: [
                offer.customerId,
                offer.craftsmanId,
              ],
              lastMessage: "",
              lastMessageTime:
                admin.firestore.FieldValue.serverTimestamp(),
              createdAt:
                admin.firestore.FieldValue.serverTimestamp(),
            });

          }

          return {
            success: true,
            chatId: offer.jobId,
          };
        });
        exports.getEmailByPhone = onCall(async (request) => {
          try {
            const { phone } = request.data;

            if (!phone) {
              throw new Error("Telefon numarası gerekli.");
            }

            let cleanPhone = String(phone)
                .replace(/\s/g, "")
                .replace(/-/g, "")
                .replace(/\(/g, "")
                .replace(/\)/g, "");

            if (cleanPhone.startsWith("0")) {
              cleanPhone = cleanPhone.substring(1);
            }

            const snapshot = await admin
                .firestore()
                .collection("users")
            .where("phone", "==", cleanPhone)
                .limit(1)
                .get();

            if (snapshot.empty) {
              return {
                success: false,
                message: "Telefon bulunamadı.",
              };
            }

            const data = snapshot.docs[0].data();
logger.info("PHONE FOUND: " + cleanPhone);
logger.info(JSON.stringify(data));
            return {
              success: true,
             email: data["email"],
            };

          } catch (e) {
            logger.error(e);

            return {
              success: false,
              message: e.toString(),
            };
          }
        });
        exports.checkRegistrationAvailability = onCall(async (request) => {
          try {
            const { email, phone } = request.data;

            if (!email || !phone) {
              return {
                success: false,
                emailExists: false,
                phoneExists: false,
                message: "E-posta ve telefon gerekli.",
              };
            }

            const cleanEmail = String(email).trim().toLowerCase();

            // TELEFONU TEK FORMATA ÇEVİR
            let cleanPhone = String(phone).replace(/\D/g, "");

            // +90 / 90 / 0 farklarını kaldır
            if (cleanPhone.startsWith("90") && cleanPhone.length >= 12) {
              cleanPhone = cleanPhone.substring(2);
            }

            if (cleanPhone.startsWith("0") && cleanPhone.length >= 11) {
              cleanPhone = cleanPhone.substring(1);
            }

            // Son 10 rakam esas alınır
            if (cleanPhone.length > 10) {
              cleanPhone = cleanPhone.substring(cleanPhone.length - 10);
            }

            let emailExists = false;
            let phoneExists = false;

            // E-POSTA KONTROLÜ
            try {
              await admin.auth().getUserByEmail(cleanEmail);
              emailExists = true;
            } catch (e) {
              if (e.code !== "auth/user-not-found") {
                logger.error("EMAIL KONTROL HATASI:", e);
              }
            }

            // TELEFON KONTROLÜ
            const phoneVariants = [
              cleanPhone,
              "0" + cleanPhone,
              "90" + cleanPhone,
              "+90" + cleanPhone,
            ];

            const usersSnapshot = await admin
                .firestore()
                .collection("users")
                .get();

            for (const doc of usersSnapshot.docs) {
              const user = doc.data();

              if (!user.phone) continue;

              let storedPhone = String(user.phone).replace(/\D/g, "");

              if (storedPhone.startsWith("90") && storedPhone.length >= 12) {
                storedPhone = storedPhone.substring(2);
              }

              if (storedPhone.startsWith("0") && storedPhone.length >= 11) {
                storedPhone = storedPhone.substring(1);
              }

              if (storedPhone.length > 10) {
                storedPhone =
                    storedPhone.substring(storedPhone.length - 10);
              }

              if (phoneVariants.includes(String(user.phone).replace(/\D/g, "")) ||
                  storedPhone === cleanPhone) {
                phoneExists = true;
                break;
              }
            }

            return {
              success: true,
              emailExists: emailExists,
              phoneExists: phoneExists,
            };

          } catch (e) {
            logger.error("KAYIT KONTROL HATASI:", e);

            return {
              success: false,
              emailExists: false,
              phoneExists: false,
              message: e.toString(),
            };
          }
        });
exports.verifyGooglePlayTokenPurchase = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Giriş yapmanız gerekiyor."
    );
  }

  const uid = request.auth.uid;

  const {
    productId,
    purchaseToken,
  } = request.data;

  if (!productId || !purchaseToken) {
    throw new HttpsError(
      "invalid-argument",
      "Ürün bilgileri eksik."
    );
  }

  const tokenPackages = {
    tokens_120: 120,
    tokens_240: 240,
    tokens_480: 480,
    tokens_960: 960,
    tokens_1920: 1920,
  };

  const tokenAmount = tokenPackages[productId];

  if (!tokenAmount) {
    throw new HttpsError(
      "invalid-argument",
      "Geçersiz ürün."
    );
  }

  const auth = new google.auth.GoogleAuth({
    credentials: serviceAccount,
    scopes: [
      "https://www.googleapis.com/auth/androidpublisher",
    ],
  });

  const androidPublisher =
      google.androidpublisher({
        version: "v3",
        auth,
      });

const packageName = "com.ustakapinda.app";

  try {
    const response =
        await androidPublisher.purchases.products.get({
          packageName: packageName,
          productId: productId,
          token: purchaseToken,
        });

    const purchase = response.data;

    if (purchase.purchaseState !== 0) {
      throw new HttpsError(
        "failed-precondition",
        "Satın alma tamamlanmamış."
      );
    }

    const db = admin.firestore();

    const purchaseRef = db
        .collection("google_play_purchases")
        .doc(purchaseToken);

    const existingPurchase =
        await purchaseRef.get();

    if (existingPurchase.exists) {
      return {
        success: true,
        alreadyProcessed: true,
      };
    }

    const userRef =
        db.collection("users").doc(uid);

    await db.runTransaction(
      async (transaction) => {
        const userDoc =
            await transaction.get(userRef);

        if (!userDoc.exists) {
          throw new HttpsError(
            "not-found",
            "Kullanıcı bulunamadı."
          );
        }

        const userData =
            userDoc.data();

        const currentTokens =
            userData.tokens ?? 0;

        transaction.update(userRef, {
          tokens:
              currentTokens + tokenAmount,
        });

        transaction.set(
          purchaseRef,
          {
            uid: uid,
            productId: productId,
            tokens: tokenAmount,
            purchaseToken: purchaseToken,
            orderId: purchase.orderId ?? null,
            createdAt:
                admin.firestore.FieldValue.serverTimestamp(),
          },
        );
      },
    );

    return {
      success: true,
      tokensAdded: tokenAmount,
    };
  } catch (error) {
    logger.error(
      "Google Play satın alma doğrulama hatası:",
      error,
    );

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      "internal",
      "Satın alma doğrulanamadı."
    );
  }
});