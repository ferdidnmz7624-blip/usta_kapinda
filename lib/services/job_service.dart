import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/job_model.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
  FirebaseFunctions.instanceFor(
    region: "europe-west1",
  );
  final String _collection = "jobs";

  Future<void> createJob(JobModel job) async {
    await _firestore
        .collection(_collection)
        .doc(job.id)
        .set(job.toMap());
  }
  Future<void> closeJob(String jobId) async {
    await _firestore
        .collection(_collection)
        .doc(jobId)
        .update({
      "status": "closed",
    });
  }
  Future<void> openJob(String jobId) async {
    await _firestore
        .collection(_collection)
        .doc(jobId)
        .update({
      "status": "active",
    });
  }
  Future<void> updateJob(JobModel job) async {
    await _firestore
        .collection(_collection)
        .doc(job.id)
        .update(job.toMap());
  }

  Future<void> deleteJob(String id) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .delete();
  }

  Stream<List<JobModel>> getJobs() {
    return _firestore
        .collection(_collection)
        .where("status", isEqualTo: "active")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.data());
      }).toList();
    });
  }

  Stream<List<JobModel>> getUserJobs(String userId) {
    return _firestore
        .collection(_collection)
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<JobModel?> getJob(String id) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return JobModel.fromMap(doc.data()!);
  }
  Future<void> updateJobStatus({
    required String jobId,
    required String status,
  }) async {
    await _functions
        .httpsCallable("updateJobStatus")
        .call({
      "jobId": jobId,
      "status": status,
    });
  }
  /// Returns only the active listings that a craftsman is eligible to see.
  ///
  /// The complete profession list is applied before results are exposed. This
  /// also supports craftsmen who selected more than Firestore's ten-value
  /// [whereIn] limit without hiding any of their matching listings.
  Stream<List<JobModel>> getJobsForCraftsman({
    required String city,
    required List<String> professions,
  }) {
    final normalizedCity = city.trim();
    final normalizedProfessions = professions
        .map((profession) => profession.trim())
        .where((profession) => profession.isNotEmpty)
        .toSet();

    if (normalizedCity.isEmpty || normalizedProfessions.isEmpty) {
      return Stream.value(const <JobModel>[]);
    }

    return _firestore
        .collection(_collection)
        .where("status", isEqualTo: "active")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JobModel.fromMap(doc.data()))
              .where(
                (job) =>
                    job.city.trim() == normalizedCity &&
                    normalizedProfessions.contains(job.category.trim()),
              )
              .toList(),
        );
  }
}
