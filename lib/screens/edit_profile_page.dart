import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../data/cities.dart';
import '../data/districts.dart';
import '../generated/app_localizations.dart';
import '../models/user_model.dart';
import '../search/search_delegates.dart';
import '../services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  File? selectedImage;

  bool isUploading = false;
  bool isLoading = true;
  bool isSaving = false;

  UserModel? user;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final addressController = TextEditingController();

  final professionController = TextEditingController();
  final experienceController = TextEditingController();
  final aboutController = TextEditingController();

  final List<String> selectedProfessions = [];

  String? firstNameError;
  String? lastNameError;
  String? phoneError;
  String? neighborhoodError;
  String? addressError;
  String? experienceError;
  String? aboutError;

  @override
  void initState() {
    super.initState();

    firstNameController.addListener(_refresh);
    lastNameController.addListener(_refresh);
    phoneController.addListener(_refresh);
    neighborhoodController.addListener(_refresh);
    addressController.addListener(_refresh);
    experienceController.addListener(_refresh);
    aboutController.addListener(_refresh);

    loadUser();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<String?> uploadProfilePhoto() async {
    if (selectedImage == null || user == null) {
      return user?.profilePhoto;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_photos")
          .child("${user!.uid}.jpg");

      await ref.putFile(selectedImage!);

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint(e.toString());
      return user?.profilePhoto;
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> loadUser() async {
    final current = FirebaseAuth.instance.currentUser;

    if (current == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    user = await _userService.getUser(current.uid);

    if (user != null) {
      firstNameController.text = user!.firstName;
      lastNameController.text = user!.lastName;
      phoneController.text = user!.phone;

      cityController.text = user!.city;
      districtController.text = user!.district;
      neighborhoodController.text = user!.neighborhood;
      addressController.text = user!.address;

      selectedProfessions.clear();
      selectedProfessions.addAll(user!.professions);

      professionController.text = selectedProfessions.join(", ");

      experienceController.text = user!.experience.toString();
      aboutController.text = user!.about;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------
  // VALIDASYONLAR
  // ------------------------------------------------------------
  void validateField(String field) {
    setState(() {
      switch (field) {
        case "firstName":
          final value = firstNameController.text.trim();

          if (value.isEmpty) {
            firstNameError = "Adınızı giriniz.";
          } else if (value.length < 3) {
            firstNameError = "Ad en az 3 karakter olmalıdır.";
          } else if (value.length > 20) {
            firstNameError = "Ad en fazla 20 karakter olabilir.";
          } else {
            firstNameError = null;
          }
          break;

        case "lastName":
          final value = lastNameController.text.trim();

          if (value.isEmpty) {
            lastNameError = "Soyadınızı giriniz.";
          } else if (value.length < 3) {
            lastNameError = "Soyad en az 3 karakter olmalıdır.";
          } else if (value.length > 30) {
            lastNameError = "Soyad en fazla 30 karakter olabilir.";
          } else {
            lastNameError = null;
          }
          break;

        case "phone":
          final value = phoneController.text.trim();

          if (value.isEmpty) {
            phoneError = "Telefon numaranızı giriniz.";
          } else if (value.length < 10) {
            phoneError = "Telefon en az 10 karakter olmalıdır.";
          } else if (value.length > 20) {
            phoneError = "Telefon en fazla 20 karakter olabilir.";
          } else if (!RegExp(r'^[0-9+]+$').hasMatch(value)) {
            phoneError = "Sadece rakam ve + işareti kullanılabilir.";
          } else {
            phoneError = null;
          }
          break;

        case "neighborhood":
          final value = neighborhoodController.text.trim();

          if (value.isEmpty) {
            neighborhoodError = "Mahalle giriniz.";
          } else if (value.length < 5) {
            neighborhoodError = "Mahalle en az 5 karakter olmalıdır.";
          } else if (value.length > 30) {
            neighborhoodError = "Mahalle en fazla 30 karakter olabilir.";
          } else {
            neighborhoodError = null;
          }
          break;

        case "address":
          final value = addressController.text.trim();

          if (value.isEmpty) {
            addressError = "Açık adres giriniz.";
          } else if (value.length < 10) {
            addressError = "Adres en az 10 karakter olmalıdır.";
          } else if (value.length > 60) {
            addressError = "Adres en fazla 60 karakter olabilir.";
          } else {
            addressError = null;
          }
          break;

        case "experience":
          final value = experienceController.text.trim();

          if (value.isEmpty) {
            experienceError = "Deneyim yılını giriniz.";
          } else {
            final number = int.tryParse(value);

            if (number == null) {
              experienceError = "Sadece rakam giriniz.";
            } else if (number < 1 || number > 100) {
              experienceError =
              "Deneyim 1 ile 100 yıl arasında olmalıdır.";
            } else {
              experienceError = null;
            }
          }
          break;

        case "about":
          final value = aboutController.text.trim();

          if (value.isEmpty) {
            aboutError = "Kendinizi tanıtınız.";
          } else if (value.length < 10) {
            aboutError = "En az 10 karakter yazmalısınız.";
          } else if (value.length > 60) {
            aboutError = "En fazla 60 karakter yazabilirsiniz.";
          } else {
            aboutError = null;
          }
          break;
      }
    });
  }
  bool validateAll() {
    bool valid = true;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final neighborhood = neighborhoodController.text.trim();
    final address = addressController.text.trim();
    final experience = experienceController.text.trim();
    final about = aboutController.text.trim();

    setState(() {
      firstNameError = null;
      lastNameError = null;
      phoneError = null;
      neighborhoodError = null;
      addressError = null;
      experienceError = null;
      aboutError = null;

      // AD
      if (firstName.isEmpty) {
        firstNameError = "Adınızı giriniz.";
        valid = false;
      } else if (firstName.length < 3) {
        firstNameError = "Ad en az 3 karakter olmalıdır.";
        valid = false;
      } else if (firstName.length > 20) {
        firstNameError = "Ad en fazla 20 karakter olabilir.";
        valid = false;
      }

      // SOYAD
      if (lastName.isEmpty) {
        lastNameError = "Soyadınızı giriniz.";
        valid = false;
      } else if (lastName.length < 3) {
        lastNameError = "Soyad en az 3 karakter olmalıdır.";
        valid = false;
      } else if (lastName.length > 30) {
        lastNameError = "Soyad en fazla 30 karakter olabilir.";
        valid = false;
      }

      // TELEFON
      if (phone.isEmpty) {
        phoneError = "Telefon numaranızı giriniz.";
        valid = false;
      } else if (phone.length < 10) {
        phoneError = "Telefon en az 10 karakter olmalıdır.";
        valid = false;
      } else if (phone.length > 20) {
        phoneError = "Telefon en fazla 20 karakter olabilir.";
        valid = false;
      } else if (!RegExp(r'^[0-9+]+$').hasMatch(phone)) {
        phoneError = "Sadece rakam ve + işareti kullanılabilir.";
        valid = false;
      }

      // MAHALLE
      if (neighborhood.isEmpty) {
        neighborhoodError = "Mahalle giriniz.";
        valid = false;
      } else if (neighborhood.length < 5) {
        neighborhoodError = "Mahalle en az 5 karakter olmalıdır.";
        valid = false;
      } else if (neighborhood.length > 30) {
        neighborhoodError = "Mahalle en fazla 30 karakter olabilir.";
        valid = false;
      }

      // ADRES
      if (address.isEmpty) {
        addressError = "Açık adres giriniz.";
        valid = false;
      } else if (address.length < 10) {
        addressError = "Adres en az 10 karakter olmalıdır.";
        valid = false;
      } else if (address.length > 60) {
        addressError = "Adres en fazla 60 karakter olabilir.";
        valid = false;
      }

      // USTA
      if (user?.activeMode == "craftsman") {
        if (experience.isEmpty) {
          experienceError = "Deneyim yılını giriniz.";
          valid = false;
        } else {
          final number = int.tryParse(experience);

          if (number == null) {
            experienceError = "Sadece rakam giriniz.";
            valid = false;
          } else if (number < 1 || number > 100) {
            experienceError = "Deneyim 1 ile 100 yıl arasında olmalıdır.";
            valid = false;
          }
        }

        if (about.isEmpty) {
          aboutError = "Kendinizi tanıtınız.";
          valid = false;
        } else if (about.length < 10) {
          aboutError = "En az 10 karakter yazmalısınız.";
          valid = false;
        } else if (about.length > 60) {
          aboutError = "En fazla 60 karakter yazabilirsiniz.";
          valid = false;
        }
      }
    });

    return valid;
  }

  // ------------------------------------------------------------
  // KAYDET
  // ------------------------------------------------------------

  Future<void> saveProfile() async {
    final l10n = AppLocalizations.of(context)!;

    if (isSaving) return;

    final valid = validateAll();

    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fixInvalidFields),
        ),
      );
      return;
    }

    if (user == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      final photoUrl = await uploadProfilePhoto();

      final updatedUser = UserModel(
        uid: user!.uid,
        accountType: user!.accountType,
        linkedCustomerUid: user!.linkedCustomerUid,
        linkedCraftsmanUid: user!.linkedCraftsmanUid,
        linkedCustomerEmail: user!.linkedCustomerEmail,
        linkedCraftsmanEmail: user!.linkedCraftsmanEmail,
        customerProfile: user!.customerProfile,
        craftsmanProfile: user!.craftsmanProfile,
        activeMode: user!.activeMode,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: user!.email,
        phone: phoneController.text.trim(),
        city: cityController.text.trim(),
        district: districtController.text.trim(),
        neighborhood: neighborhoodController.text.trim(),
        address: addressController.text.trim(),
        professions: selectedProfessions,
        experience:
        int.tryParse(experienceController.text.trim()) ?? 0,
        about: aboutController.text.trim(),
        profilePhoto: photoUrl ?? user!.profilePhoto,
        rating: user!.rating,
        completedJobs: user!.completedJobs,
        tokens: user!.tokens,
        isFrozen: user!.isFrozen,
        isDeleting: user!.isDeleting,
        appReviewOtpBypass: user!.appReviewOtpBypass,
        deleteAt: user!.deleteAt,
        createdAt: user!.createdAt,
        isOnline: user!.isOnline,
        lastSeen: user!.lastSeen,
      );

      await _userService.updateUser(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdated),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.profileUpdateFailed(e.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // INPUT DECORATION
  // ------------------------------------------------------------

  InputDecoration fieldDecoration({
    required String label,
    required IconData icon,
    String? errorText,
    Widget? suffix,
    String? counterText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      errorText: errorText,
      counterText: counterText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : Colors.blue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileEditing),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ------------------------------------------------------
          // PROFİL FOTOĞRAFI
          // ------------------------------------------------------

          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : (user?.profilePhoto.isNotEmpty == true
                      ? NetworkImage(user!.profilePhoto)
                      : null) as ImageProvider?,
                  child: selectedImage == null &&
                      (user?.profilePhoto.isEmpty ?? true)
                      ? const Icon(
                    Icons.person,
                    size: 55,
                  )
                      : null,
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------------
          // AD
          // ------------------------------------------------------

          TextField(
            controller: firstNameController,
            maxLength: 20,
            textCapitalization: TextCapitalization.words,
            decoration: fieldDecoration(
              label: l10n.firstName,
              icon: Icons.person,
              errorText: firstNameError,
            ),
            onChanged: (_) {
              validateField("firstName");
            },
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // SOYAD
          // ------------------------------------------------------

          TextField(
            controller: lastNameController,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            decoration: fieldDecoration(
              label: l10n.lastName,
              icon: Icons.badge_outlined,
              errorText: lastNameError,
            ),
            onChanged: (_) {
              validateField("lastName");
            },
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // TELEFON
          // ------------------------------------------------------

          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 20,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[0-9+]'),
              ),
            ],
            decoration: fieldDecoration(
              label: l10n.phone,
              icon: Icons.phone,
              errorText: phoneError,
            ),
            onChanged: (_) {
              validateField("phone");
            },
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // İL
          // ------------------------------------------------------

          TextField(
            controller: cityController,
            readOnly: true,
            decoration: fieldDecoration(
              label: l10n.city,
              icon: Icons.location_city,
              suffix: const Icon(Icons.arrow_drop_down),
            ),
            onTap: () async {
              final result = await showSearch<String>(
                context: context,
                delegate: CitySearchDelegate(),
              );

              if (result != null) {
                setState(() {
                  cityController.text = result;
                  districtController.clear();
                });
              }
            },
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // İLÇE
          // ------------------------------------------------------

          TextField(
            controller: districtController,
            readOnly: true,
            decoration: fieldDecoration(
              label: l10n.district,
              icon: Icons.location_on,
              suffix: const Icon(Icons.arrow_drop_down),
            ),
            onTap: () async {
              if (cityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.selectCityFirst),
                  ),
                );
                return;
              }

              final result = await showSearch<String>(
                context: context,
                delegate: DistrictSearchDelegate(
                  city: cityController.text,
                ),
              );

              if (result != null) {
                setState(() {
                  districtController.text = result;
                });
              }
            },
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // MAHALLE
          // ------------------------------------------------------

          TextField(
            controller: neighborhoodController,
            maxLength: 30,
            decoration: fieldDecoration(
              label: l10n.neighborhood,
              icon: Icons.home,
              errorText: neighborhoodError,
            ),
            onChanged: (_) {
              validateField("neighborhood");
            },
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // ADRES
          // ------------------------------------------------------

          TextField(
            controller: addressController,
            maxLength: 60,
            maxLines: 3,
            decoration: fieldDecoration(
              label: l10n.address,
              icon: Icons.location_pin,
              errorText: addressError,
              counterText: "${addressController.text.length}/60",
            ),
            onChanged: (_) {
              validateField("address");
            },
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // USTA ALANLARI
          // ------------------------------------------------------

          if (user?.activeMode == "craftsman") ...[
            TextField(
              controller: professionController,
              readOnly: true,
              decoration: fieldDecoration(
                label: l10n.professions,
                icon: Icons.handyman,
                suffix: const Icon(Icons.arrow_drop_down),
              ),
              onTap: () async {
                final result = await showSearch<String>(
                  context: context,
                  delegate: CategorySearchDelegate(),
                );

                if (result != null &&
                    !selectedProfessions.contains(result)) {
                  setState(() {
                    selectedProfessions.add(result);
                    professionController.text =
                        selectedProfessions.join(", ");
                  });
                }
              },
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedProfessions.map((profession) {
                return Chip(
                  label: Text(profession),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      selectedProfessions.remove(profession);
                      professionController.text =
                          selectedProfessions.join(", ");
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 15),

            // ----------------------------------------------------
            // DENEYİM
            // ----------------------------------------------------

            TextField(
              controller: experienceController,
              keyboardType: TextInputType.number,
              maxLength: 3,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: fieldDecoration(
                label: l10n.experienceYears,
                icon: Icons.star,
                errorText: experienceError,
              ),
              onChanged: (_) {
                validateField("experience");
              },
            ),

            const SizedBox(height: 15),

            // ----------------------------------------------------
            // HAKKIMDA
            // ----------------------------------------------------

            TextField(
              controller: aboutController,
              maxLength: 60,
              maxLines: 4,
              decoration: fieldDecoration(
                label: l10n.aboutYourself,
                icon: Icons.description_outlined,
                errorText: aboutError,
                counterText: "${aboutController.text.length}/60",
              ),
              onChanged: (_) {
                validateField("about");
              },
            ),
          ],

          const SizedBox(height: 30),

          // ------------------------------------------------------
          // KAYDET
          // ------------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : saveProfile,
              icon: isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.save),
              label: Text(
                isSaving ? l10n.saving : l10n.save,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    districtController.dispose();
    neighborhoodController.dispose();
    addressController.dispose();
    professionController.dispose();
    experienceController.dispose();
    aboutController.dispose();

    super.dispose();
  }
}
