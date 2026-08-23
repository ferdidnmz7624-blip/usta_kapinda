const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentWritten,
} = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const { setGlobalOptions } = require("firebase-functions/v2");
const nodemailer = require("nodemailer");
const { defineSecret } = require("firebase-functions/params");
const { google } = require("googleapis");
const crypto = require("crypto");
const EMAIL_PASSWORD = defineSecret("EMAIL_PASSWORD");

function generateVerificationCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

const verificationPurposes = new Set([
  "registration",
  "login",
  "password_reset",
]);

function normalizeEmail(email) {
  return String(email || "").trim().toLowerCase();
}

function verificationKey(email, purpose) {
  return crypto
      .createHash("sha256")
      .update(`${purpose}:${normalizeEmail(email)}`)
      .digest("hex");
}

function codeHash(email, purpose, code) {
  return crypto
      .createHash("sha256")
      .update(`${normalizeEmail(email)}:${purpose}:${code}`)
      .digest("hex");
}

function requestIp(req) {
  const forwarded = String(req.headers["x-forwarded-for"] || "");
  return (forwarded.split(",")[0].trim() || req.ip || "unknown").slice(0, 128);
}

// E-posta doğrulama uç noktaları oturum öncesi çağrıldığından, kötüye
// kullanımı sınırlamak için e-posta başına beklemeye ek olarak IP bazlı
// pencere uygulanır. Bu koleksiyonun istemci erişimi Firestore kurallarıyla
// tamamen kapalıdır.
async function enforceVerificationRateLimit(req, purpose) {
  const db = admin.firestore();
  const key = crypto.createHash("sha256")
      .update(`${purpose}:${requestIp(req)}`).digest("hex");
  const ref = db.collection("verification_rate_limits").doc(key);
  const now = Date.now();
  const windowMs = 15 * 60 * 1000;
  const maxRequests = 12;

  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const data = snapshot.exists ? snapshot.data() : {};
    const windowStartedAt = Number(data.windowStartedAt || now);
    const withinWindow = now - windowStartedAt < windowMs;
    const count = withinWindow ? Number(data.count || 0) : 0;
    if (count >= maxRequests) {
      throw new HttpsError(
          "resource-exhausted",
          "Çok fazla kod isteği. Lütfen daha sonra tekrar deneyin.",
      );
    }
    transaction.set(ref, {
      windowStartedAt: withinWindow ? windowStartedAt : now,
      count: count + 1,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
}

admin.initializeApp();

// Ham users belgelerinde telefon, e-posta, adres, FCM belirteci, jeton ve
// hesap bağlantıları bulunur. İstemci yalnızca aşağıdaki sınırlı profili
// okuyabilir; bu belge güvenilir sunucu tarafından türetilir.
function toPublicProfile(user) {
  return {
    uid: String(user.uid || ""),
    accountType: String(user.accountType || "customer"),
    customerProfile: user.customerProfile === true,
    craftsmanProfile: user.craftsmanProfile === true,
    firstName: String(user.firstName || ""),
    lastName: String(user.lastName || ""),
    city: String(user.city || ""),
    district: String(user.district || ""),
    professions: Array.isArray(user.professions) ? user.professions : [],
    experience: Number.isFinite(user.experience) ? user.experience : 0,
    about: String(user.about || ""),
    profilePhoto: String(user.profilePhoto || ""),
    rating: Number.isFinite(user.rating) ? user.rating : 5,
    completedJobs: Number.isFinite(user.completedJobs) ? user.completedJobs : 0,
    isOnline: user.isOnline === true,
    lastSeen: user.lastSeen || null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

exports.syncPublicProfile = onDocumentWritten(
  "users/{userId}",
  async (event) => {
    const publicRef = admin.firestore()
        .collection("public_profiles").doc(event.params.userId);
    if (!event.data || !event.data.after.exists) {
      await publicRef.delete();
      return;
    }
    await publicRef.set(toPublicProfile(event.data.after.data()));
  },
);

setGlobalOptions({
  region: "europe-west1",
  maxInstances: 10,
});

// iOS bildirimlerinde ses, APNs payload'ında açıkça belirtilmelidir.
const iOSNotificationOptions = {
  headers: {
    "apns-priority": "10",
  },
  payload: {
    aps: {
      sound: "default",
    },
  },
};

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
        apns: iOSNotificationOptions,
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
        apns: iOSNotificationOptions,
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
        apns: iOSNotificationOptions,
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
        apns: iOSNotificationOptions,
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
        apns: iOSNotificationOptions,
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
          apns: iOSNotificationOptions,
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
      const email = normalizeEmail(req.body.email);
      const purpose = String(req.body.purpose || "registration");

      if (!email || !verificationPurposes.has(purpose)) {
        return res.status(400).json({
          success: false,
          message: "Geçersiz doğrulama isteği.",
        });
      }

      await enforceVerificationRateLimit(req, purpose);

      const verificationRef = admin.firestore()
          .collection("email_verifications")
          .doc(verificationKey(email, purpose));
      const now = Date.now();
      const previous = await verificationRef.get();
      if (previous.exists && now - (previous.data().lastSentAt || 0) < 50 * 1000) {
        return res.status(429).json({
          success: false,
          message: "Yeni kod için lütfen kısa süre bekleyin.",
        });
      }

      const code = generateVerificationCode();
      await verificationRef.set({
        email,
        purpose,
        codeHash: codeHash(email, purpose, code),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastSentAt: now,
        expiresAt: now + 2 * 60 * 1000,
        attempts: 0,
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
        subject: "Usta Kapında doğrulama kodu",
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
      if (e instanceof HttpsError && e.code === "resource-exhausted") {
        return res.status(429).json({success: false, message: e.message});
      }
      logger.error(e);

      return res.status(500).json({
        success: false,
        message: "Doğrulama kodu gönderilemedi.",
      });
    }
  }
);
exports.verifyVerificationCode = onRequest(async (req, res) => {
  try {
    const email = normalizeEmail(req.body.email);
    const { code } = req.body;
    const purpose = String(req.body.purpose || "registration");

    if (!email || !code || !verificationPurposes.has(purpose)) {
      return res.status(400).json({
        success: false,
        message: "Eksik bilgi.",
      });
    }

    const verificationRef = admin.firestore()
        .collection("email_verifications")
        .doc(verificationKey(email, purpose));
    const doc = await verificationRef.get();

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

    if ((data.attempts || 0) >= 5) {
      await verificationRef.delete();
      return res.status(429).json({
        success: false,
        message: "Çok fazla hatalı deneme. Yeni kod isteyin.",
      });
    }

    if (data.codeHash !== codeHash(email, purpose, code)) {
      await verificationRef.update({
        attempts: admin.firestore.FieldValue.increment(1),
      });
      return res.json({
        success: false,
        message: "Kod yanlış.",
      });
    }

    await verificationRef.delete();
    if (purpose === "password_reset") {
      const resetToken = crypto.randomBytes(32).toString("hex");
      await admin.firestore().collection("password_reset_tokens")
          .doc(verificationKey(email, purpose))
          .set({
            tokenHash: crypto.createHash("sha256").update(resetToken).digest("hex"),
            expiresAt: Date.now() + 10 * 60 * 1000,
          });
      return res.json({ success: true, resetToken });
    }
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
    const email = normalizeEmail(req.body.email);
    const { password, resetToken } = req.body;

    if (!email || !password || !resetToken || password.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Eksik bilgi.",
      });
    }

    const tokenRef = admin.firestore().collection("password_reset_tokens")
        .doc(verificationKey(email, "password_reset"));
    const tokenDoc = await tokenRef.get();
    const suppliedHash = crypto.createHash("sha256")
        .update(String(resetToken)).digest("hex");
    if (!tokenDoc.exists || Date.now() > tokenDoc.data().expiresAt ||
        tokenDoc.data().tokenHash !== suppliedHash) {
      return res.status(403).json({
        success: false,
        message: "Parola sıfırlama oturumu geçersiz veya süresi dolmuş.",
      });
    }

    const user = await admin.auth().getUserByEmail(email);

    await admin.auth().updateUser(user.uid, {
      password: password,
    });
    await tokenRef.delete();

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
    typeof price !== "number" || !Number.isFinite(price) ||
    typeof message !== "string" ||
    typeof estimatedDays !== "number" || !Number.isInteger(estimatedDays)
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

    if (!Number.isFinite(budget) || budget <= 0) {
      throw new HttpsError("failed-precondition", "İlan bütçesi geçersiz.");
    }

    if (userData.accountType !== "craftsman" ||
        userData.craftsmanProfile !== true ||
        userData.isFrozen === true || userData.isDeleting === true) {
      throw new HttpsError(
        "permission-denied",
        "Yalnızca aktif usta hesapları teklif verebilir.",
      );
    }

    if (jobData.userId === uid || jobData.status !== "active") {
      throw new HttpsError(
        "failed-precondition",
        "Bu ilana teklif verilemez.",
      );
    }

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

        const existingOfferQuery = db
            .collection("offers")
            .where("jobId", "==", jobId)
            .where("craftsmanId", "==", uid)
            .limit(1);
        const existingOffer = await transaction.get(existingOfferQuery);

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

          if (offer.status !== "pending") {
            throw new HttpsError(
              "failed-precondition",
              "Yalnızca bekleyen teklifler kabul edilebilir.",
            );
          }

          await offerRef.update({
            status: "accepted",
          });

          await db.collection("notifications").add({
            userId: offer.craftsmanId,
            title: "Teklif kabul edildi",
            body: `'${offer.jobTitle}' ilanındaki teklifiniz kabul edildi.`,
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
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

          if (offer.status !== "pending") {
            throw new HttpsError(
              "failed-precondition",
              "Yalnızca bekleyen teklifler reddedilebilir.",
            );
          }

          await offerRef.update({
            status: "rejected",
          });

          await db.collection("notifications").add({
            userId: offer.craftsmanId,
            title: "Teklif reddedildi",
            body: `'${offer.jobTitle}' ilanındaki teklifiniz reddedildi.`,
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
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

const isCustomer = offer.customerId === uid;
const isCraftsman = offer.craftsmanId === uid;
const permittedByRole =
  (currentStatus === "pending" && isCustomer) ||
  (currentStatus === "accepted" &&
    ["in_progress", "cancelled"].includes(status) &&
    (isCustomer || isCraftsman)) ||
  (currentStatus === "in_progress" &&
    ["completed", "cancelled"].includes(status) &&
    (isCustomer || isCraftsman)) ||
  (currentStatus === "completed" && status === "reviewed" &&
    (isCustomer || isCraftsman));

if (!permittedByRole) {
  throw new HttpsError(
    "permission-denied",
    "Bu durum değişikliğine yetkiniz yok.",
  );
}
          const jobRef = db.collection("jobs").doc(offer.jobId);
          const jobStatusByOfferStatus = {
            in_progress: "in_progress",
            completed: "completed",
            cancelled: "cancelled",
          };

          await db.runTransaction(async (transaction) => {
            transaction.update(offerRef, {status});

            const jobStatus = jobStatusByOfferStatus[status];
            if (jobStatus) {
              transaction.update(jobRef, {status: jobStatus});
            }
          });

          if (["completed", "cancelled"].includes(status)) {
            const chatRef = db.collection("chats").doc(offer.jobId);
            const messages = await chatRef.collection("messages").get();
            await Promise.all(messages.docs.map((message) => message.ref.delete()));
            await chatRef.delete();
          }

          return { success: true };
        });
        exports.submitReview = onCall(async (request) => {
          if (!request.auth) {
            throw new HttpsError(
              "unauthenticated",
              "Giriş yapmanız gerekiyor.",
            );
          }

          const { jobId, reviewerType, rating, comment } = request.data;
          const uid = request.auth.uid;
          if (
            typeof jobId !== "string" ||
            !["customer", "craftsman"].includes(reviewerType) ||
            typeof rating !== "number" ||
            rating < 1 || rating > 5 || rating % 1 !== 0 ||
            typeof comment !== "string" ||
            comment.trim().length === 0 || comment.length > 1000
          ) {
            throw new HttpsError(
              "invalid-argument",
              "Geçersiz değerlendirme bilgisi.",
            );
          }

          const db = admin.firestore();
          const offers = await db.collection("offers")
              .where("jobId", "==", jobId)
              .get();
          const offerDoc = offers.docs.find((doc) => {
            const offer = doc.data();
            return reviewerType === "customer" ?
              offer.customerId === uid : offer.craftsmanId === uid;
          });

          if (!offerDoc) {
            throw new HttpsError(
              "permission-denied",
              "Bu iş için değerlendirme yapma yetkiniz yok.",
            );
          }

          const reviewer = reviewerType === "customer" ?
            "customer" : "craftsman";
          const offerRef = offerDoc.ref;
          const reviewerDoc = await db.collection("users").doc(uid).get();
          const reviewerData = reviewerDoc.data() || {};
          const reviewRef = db.collection("reviews").doc();

          await db.runTransaction(async (transaction) => {
            const currentOfferDoc = await transaction.get(offerRef);
            if (!currentOfferDoc.exists) {
              throw new HttpsError("not-found", "Teklif bulunamadı.");
            }

            const offer = currentOfferDoc.data();
            const isExpectedReviewer = reviewer === "customer" ?
              offer.customerId === uid : offer.craftsmanId === uid;
            const reviewFlag = reviewer === "customer" ?
              "customerReviewed" : "craftsmanReviewed";
            if (
              !isExpectedReviewer ||
              !["completed", "reviewed"].includes(offer.status) ||
              offer[reviewFlag] === true
            ) {
              throw new HttpsError(
                "failed-precondition",
                "Bu değerlendirme artık gönderilemez.",
              );
            }

            const targetUserId = reviewer === "customer" ?
              offer.craftsmanId : offer.customerId;
            const reviewData = {
              id: reviewRef.id,
              customerId: offer.customerId,
              craftsmanId: offer.craftsmanId,
              jobId: offer.jobId,
              reviewerType: reviewer,
              reviewerId: uid,
              rating,
              comment: comment.trim(),
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            transaction.create(reviewRef, reviewData);
            transaction.set(
                db.collection("users").doc(targetUserId)
                    .collection("reviews").doc(reviewRef.id),
                {
                  ...reviewData,
                  userName: `${reviewerData.firstName || ""} ${reviewerData.lastName || ""}`.trim(),
                  userPhoto: reviewerData.profilePhoto || "",
                },
            );
            transaction.update(offerRef, {
              [reviewFlag]: true,
              status: (reviewer === "customer" ?
                offer.craftsmanReviewed : offer.customerReviewed) === true ?
                "reviewed" : offer.status,
            });
          });

          return {success: true, reviewId: reviewRef.id};
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
            type = "text",
            fileUrl = "",
            fileName = "",
          } = request.data;

          if (!chatId || !senderId || !receiverId) {
            throw new Error("Eksik parametre.");
          }

          if (request.auth.uid !== senderId) {
            throw new Error("Yetkiniz yok.");
          }

          const isTextMessage = type === "text" && typeof message === "string" &&
              message.trim().length > 0 && message.length <= 4000;
          const isImageMessage = type === "image" && typeof fileUrl === "string" &&
              fileUrl.startsWith("https://") && fileUrl.length <= 4000 &&
              typeof fileName === "string" && fileName.length <= 255;
          if (!isTextMessage && !isImageMessage) {
            throw new HttpsError(
              "invalid-argument",
              "Geçersiz mesaj.",
            );
          }

          const db = admin.firestore();

          const chatRef = db.collection("chats").doc(chatId);

          const chatDoc = await chatRef.get();
          if (!chatDoc.exists) {
            throw new HttpsError("not-found", "Sohbet bulunamadı.");
          }

          const chat = chatDoc.data();
          const chatUsers = Array.isArray(chat.users) ? chat.users : [];
          if (
            !chatUsers.includes(senderId) ||
            !chatUsers.includes(receiverId) ||
            senderId === receiverId
          ) {
            throw new HttpsError(
              "permission-denied",
              "Bu sohbete mesaj gönderme yetkiniz yok.",
            );
          }

          // Engelleme listeleri gizli kullanıcı belgelerinde tutulur. İstemci
          // karşı tarafın listesini okuyamadığı için bu kontrol sunucuda
          // zorunludur; değiştirilmiş uygulama paketiyle atlanamaz.
          const [senderUserDoc, receiverUserDoc] = await Promise.all([
            db.collection("users").doc(senderId).get(),
            db.collection("users").doc(receiverId).get(),
          ]);
          const senderBlocked = senderUserDoc.exists &&
              Array.isArray(senderUserDoc.data().blockedUsers) ?
            senderUserDoc.data().blockedUsers : [];
          const receiverBlocked = receiverUserDoc.exists &&
              Array.isArray(receiverUserDoc.data().blockedUsers) ?
            receiverUserDoc.data().blockedUsers : [];
          if (senderBlocked.includes(receiverId) ||
              receiverBlocked.includes(senderId)) {
            throw new HttpsError(
              "permission-denied",
              "Kullanıcılardan biri diğerini engellediği için mesaj gönderilemez.",
            );
          }

          const offerSnapshot = await db
              .collection("offers")
              .where("jobId", "==", chat.jobId)
              .get();

          const chatOffer = offerSnapshot.docs
              .map((doc) => doc.data())
              .find((offer) =>
                offer.customerId === chat.customerId &&
                offer.craftsmanId === chat.craftsmanId,
              );

          if (!chatOffer || ![
            "accepted",
            "in_progress",
          ].includes(chatOffer.status)) {
            throw new HttpsError(
              "failed-precondition",
              "Bu iş için mesajlaşma kapalı.",
            );
          }

          await chatRef.collection("messages").add({
            senderId,
            receiverId,
            message: isTextMessage ? message.trim() : "",
            type,
            fileUrl: isImageMessage ? fileUrl : "",
            fileName: isImageMessage ? fileName : "",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            status: "sent",
          });

          const lastMessage = isTextMessage ? message.trim() : "📷 Fotoğraf";
          await chatRef.set({
            lastMessage,
            lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
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
        exports.clearChatForUser = onCall(async (request) => {
          if (!request.auth) {
            throw new HttpsError("unauthenticated", "Giriş yapmanız gerekiyor.");
          }

          const {chatId, hideFromList = false} = request.data;
          if (typeof chatId !== "string" || typeof hideFromList !== "boolean") {
            throw new HttpsError("invalid-argument", "Geçersiz sohbet isteği.");
          }

          const chatRef = admin.firestore().collection("chats").doc(chatId);
          const chatDoc = await chatRef.get();
          if (!chatDoc.exists || !Array.isArray(chatDoc.data().users) ||
              !chatDoc.data().users.includes(request.auth.uid)) {
            throw new HttpsError("permission-denied", "Bu sohbete erişim yetkiniz yok.");
          }

          const uid = request.auth.uid;
          const update = {
            [`clearedBy.${uid}`]: admin.firestore.FieldValue.serverTimestamp(),
          };
          if (hideFromList) {
            update[`deletedBy.${uid}`] = true;
          }
          await chatRef.update(update);
          return {success: true};
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

            let cleanPhone = String(phone).replace(/\D/g, "");
            if (cleanPhone.startsWith("90") && cleanPhone.length === 12) {
              cleanPhone = cleanPhone.substring(2);
            }
            if (cleanPhone.startsWith("0") && cleanPhone.length === 11) {
              cleanPhone = cleanPhone.substring(1);
            }
            if (cleanPhone.length !== 10) {
              return {
                success: false,
                message: "Geçersiz telefon numarası.",
              };
            }
            // Yalnızca Firebase Auth'ta SMS ile doğrulanıp hesaba bağlanmış
            // telefonlar giriş tanımlayıcısı olarak kullanılabilir.
            const authUser = await admin.auth().getUserByPhoneNumber(`+90${cleanPhone}`);
            return {
              success: true,
              email: authUser.email,
            };

          } catch (e) {
            if (e.code !== "auth/user-not-found") {
              logger.error(e);
            }

            return {
              success: false,
              message: e.toString(),
            };
          }
        });
        exports.linkAccounts = onCall(async (request) => {
          const sourceIdToken = String(request.data?.sourceIdToken || "");
          const targetIdToken = String(request.data?.targetIdToken || "");
          if (!sourceIdToken || !targetIdToken) {
            throw new HttpsError(
                "invalid-argument",
                "Her iki hesap için de oturum kanıtı gerekli.",
            );
          }

          let sourceToken;
          let targetToken;
          try {
            [sourceToken, targetToken] = await Promise.all([
              admin.auth().verifyIdToken(sourceIdToken),
              admin.auth().verifyIdToken(targetIdToken),
            ]);
          } catch (_) {
            throw new HttpsError(
                "permission-denied",
                "Bağlanacak hesapların oturumları doğrulanamadı.",
            );
          }

          const sourceUid = sourceToken.uid;
          const targetUid = targetToken.uid;
          if (sourceUid === targetUid) {
            throw new HttpsError(
                "failed-precondition",
                "Aynı hesap kendi kendisiyle bağlanamaz.",
            );
          }

          const db = admin.firestore();
          await db.runTransaction(async (transaction) => {
            const sourceRef = db.collection("users").doc(sourceUid);
            const targetRef = db.collection("users").doc(targetUid);
            const [sourceSnapshot, targetSnapshot] = await Promise.all([
              transaction.get(sourceRef),
              transaction.get(targetRef),
            ]);

            if (!sourceSnapshot.exists || !targetSnapshot.exists) {
              throw new HttpsError(
                  "not-found",
                  "Bağlanacak hesaplardan biri bulunamadı.",
              );
            }

            const source = sourceSnapshot.data();
            const target = targetSnapshot.data();
            const sourceType = source.accountType;
            const targetType = target.accountType;
            if (!(["customer", "craftsman"].includes(sourceType)) ||
                !(["customer", "craftsman"].includes(targetType)) ||
                sourceType === targetType) {
              throw new HttpsError(
                  "failed-precondition",
                  "Müşteri ve usta hesabı birbirinden farklı olmalıdır.",
              );
            }

            const customer = sourceType === "customer" ? source : target;
            const craftsman = sourceType === "craftsman" ? source : target;
            const customerUid = sourceType === "customer" ? sourceUid : targetUid;
            const craftsmanUid = sourceType === "craftsman" ? sourceUid : targetUid;

            if ((customer.linkedCraftsmanUid || "") &&
                customer.linkedCraftsmanUid !== craftsmanUid) {
              throw new HttpsError(
                  "already-exists",
                  "Müşteri hesabı başka bir usta hesabına bağlı.",
              );
            }
            if ((craftsman.linkedCustomerUid || "") &&
                craftsman.linkedCustomerUid !== customerUid) {
              throw new HttpsError(
                  "already-exists",
                  "Usta hesabı başka bir müşteri hesabına bağlı.",
              );
            }

            transaction.update(db.collection("users").doc(customerUid), {
              linkedCraftsmanUid: craftsmanUid,
              linkedCraftsmanEmail: String(craftsman.email || ""),
            });
            transaction.update(db.collection("users").doc(craftsmanUid), {
              linkedCustomerUid: customerUid,
              linkedCustomerEmail: String(customer.email || ""),
            });
          });

          return { success: true };
        });
        exports.checkRegistrationAvailability = onCall(async (request) => {
          try {
            const { email, phone } = request.data;

            if (!email) {
              return {
                success: false,
                emailExists: false,
                phoneExists: false,
                message: "E-posta gerekli.",
              };
            }

            const cleanEmail = String(email).trim().toLowerCase();

            // TELEFONU TEK FORMATA ÇEVİR
            let cleanPhone = String(phone || "").replace(/\D/g, "");

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
            const phoneVariants = cleanPhone ? [
                cleanPhone,
                "0" + cleanPhone,
                "90" + cleanPhone,
                "+90" + cleanPhone,
            ] : [];

            const usersSnapshot = await admin
                .firestore()
                .collection("users")
                .get();

            for (const doc of usersSnapshot.docs) {
              if (!cleanPhone) break;
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

    // İstemcinin gönderdiği ürün kimliği, Google'ın doğruladığı satın almayla
    // birebir eşleşmelidir. Böylece farklı bir paketin makbuzu kullanılamaz.
    if (purchase.productId && purchase.productId !== productId) {
      throw new HttpsError(
        "failed-precondition",
        "Satın alma paketi doğrulanamadı.",
      );
    }

    const db = admin.firestore();

    const purchaseRef = db
        .collection("google_play_purchases")
        .doc(purchaseToken);

    const userRef =
        db.collection("users").doc(uid);

    const transactionResult = await db.runTransaction(
      async (transaction) => {
        // Aynı Google purchase token'ının eşzamanlı iki istekte iki kez
        // bakiyeye yazılmaması için hem makbuz hem kullanıcı bu transaction
        // içinde okunur ve yazılır.
        const [existingPurchase, userDoc] = await Promise.all([
          transaction.get(purchaseRef),
          transaction.get(userRef),
        ]);

        if (existingPurchase.exists) {
          const purchaseData = existingPurchase.data();
          if (purchaseData.uid !== uid) {
            throw new HttpsError(
              "already-exists",
              "Bu Google Play satın alması başka bir hesapta kullanılmış.",
            );
          }
          return {alreadyProcessed: true};
        }

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
        return {alreadyProcessed: false};
      },
    );

    return {
      success: true,
      tokensAdded: tokenAmount,
      alreadyProcessed: transactionResult.alreadyProcessed,
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

/**
 * Apple App Store'daki tüketilebilir jeton paketlerini doğrular ve jetonu
 * yalnızca Apple'ın onayladığı işlem için kullanıcının hesabına ekler.
 *
 * StoreKit 1 makbuzu önce üretim Apple sunucusuna gönderilir. TestFlight ve
 * sandbox makbuzlarında Apple 21007 döndürdüğünden, yalnızca bu durumda
 * sandbox sunucusu tekrar denenir.
 */
exports.verifyAppStoreTokenPurchase = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Giriş yapmanız gerekiyor."
    );
  }

  const {
    productId,
    receiptData,
    transactionId,
  } = request.data;

  if (!productId || !receiptData || !transactionId) {
    throw new HttpsError(
      "invalid-argument",
      "Apple satın alma bilgileri eksik."
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

  const verifyReceipt = async (url) => {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        "receipt-data": receiptData,
        "exclude-old-transactions": false,
      }),
    });

    if (!response.ok) {
      throw new Error(`Apple makbuz doğrulama isteği başarısız: ${response.status}`);
    }

    return response.json();
  };

  try {
    let verification = await verifyReceipt(
      "https://buy.itunes.apple.com/verifyReceipt"
    );

    if (verification.status === 21007) {
      verification = await verifyReceipt(
        "https://sandbox.itunes.apple.com/verifyReceipt"
      );
    }

    if (verification.status !== 0) {
      throw new HttpsError(
        "failed-precondition",
        "Apple satın almayı doğrulayamadı."
      );
    }

    const receipt = verification.receipt;

    if (receipt?.bundle_id !== "com.ustakapinda.app") {
      throw new HttpsError(
        "failed-precondition",
        "Makbuz bu uygulamaya ait değil."
      );
    }

    const matchingPurchase = (receipt.in_app ?? []).find(
      (purchase) =>
        purchase.product_id === productId &&
        purchase.transaction_id === transactionId
    );

    if (!matchingPurchase) {
      throw new HttpsError(
        "failed-precondition",
        "Makbuzdaki satın alma işlemi bulunamadı."
      );
    }

    const db = admin.firestore();
    const purchaseRef = db
      .collection("app_store_purchases")
      .doc(transactionId);
    const userRef = db.collection("users").doc(request.auth.uid);

    const transactionResult = await db.runTransaction(async (transaction) => {
      const [existingPurchase, userDoc] = await Promise.all([
        transaction.get(purchaseRef),
        transaction.get(userRef),
      ]);

      if (existingPurchase.exists) {
        const existingData = existingPurchase.data();

        if (existingData.uid !== request.auth.uid) {
          throw new HttpsError(
            "already-exists",
            "Bu Apple satın alması başka bir hesapta kullanılmış."
          );
        }

        return { alreadyProcessed: true };
      }

      if (!userDoc.exists) {
        throw new HttpsError(
          "not-found",
          "Kullanıcı bulunamadı."
        );
      }

      const currentTokens = userDoc.data().tokens ?? 0;

      transaction.update(userRef, {
        tokens: currentTokens + tokenAmount,
      });

      transaction.set(purchaseRef, {
        uid: request.auth.uid,
        productId,
        tokens: tokenAmount,
        transactionId,
        originalTransactionId:
          matchingPurchase.original_transaction_id ?? transactionId,
        environment: verification.environment ?? null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { alreadyProcessed: false };
    });

    return {
      success: true,
      tokensAdded: tokenAmount,
      alreadyProcessed: transactionResult.alreadyProcessed,
    };
  } catch (error) {
    logger.error("Apple App Store satın alma doğrulama hatası:", error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      "internal",
      "Apple satın alması doğrulanamadı."
    );
  }
});
