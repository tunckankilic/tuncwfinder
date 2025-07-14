import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:tuncforwork/theme/app_theme.dart';
import 'package:tuncforwork/models/models.dart';
import 'package:tuncforwork/service/validation.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/widgets/modern_widgets.dart';

class RegistrationScreen extends GetView<AuthController> {
  static const routeName = "/register";
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 768) {
              return _buildTabletLayout(context);
            }
            return _buildMobileLayout(context);
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Obx(() => PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStartPage(false),
            _buildPersonalInfoPage(false),
            _buildAppearancePage(false),
            _buildLifestylePage(false),
            _buildCareerPage(false),
          ],
        ));
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Sol taraf - Progress ve bilgi
        Expanded(
          flex: 2,
          child: Container(
            color: AppTheme.primarySwatch.shade50,
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 48),
                Obx(() => _buildProgressIndicator(true)),
                const SizedBox(height: 48),
                _buildPageInfo(true),
              ],
            ),
          ),
        ),
        // Sağ taraf - Form
        Expanded(
          flex: 3,
          child: Obx(() => PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStartPage(true),
                  _buildPersonalInfoPage(true),
                  _buildAppearancePage(true),
                  _buildLifestylePage(true),
                  _buildCareerPage(true),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${controller.currentPage.value + 1} of 5',
          style: AppTheme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: (controller.currentPage.value + 1) / 5,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primarySwatch),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPageInfo(bool isTablet) {
    final titles = [
      'Get Started',
      'Personal Information',
      'Appearance',
      'Lifestyle',
      'Career'
    ];
    final descriptions = [
      'Create your account to get started',
      'Tell us about yourself',
      'Add your physical characteristics',
      'Share your lifestyle preferences',
      'Tell us about your career'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[controller.currentPage.value],
          style: AppTheme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          descriptions[controller.currentPage.value],
          style: AppTheme.textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildStartPage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 48.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isTablet) ...[
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),
            _buildProgressIndicator(false),
            const SizedBox(height: 32),
          ],
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileImagePicker(isTablet),
                SizedBox(height: 24.h),
                TextField(
                  controller: controller.nameController,
                  decoration: AppTheme.inputDecoration.copyWith(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: controller.emailController,
                  decoration: AppTheme.inputDecoration.copyWith(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),
                PasswordInputField(
                  controller: controller.passwordController,
                  label: 'Password',
                  isConfirmField: false,
                  isTablet: isTablet,
                  authController: controller,
                  onChanged: (value) {
                    controller.validatePassword(value);
                  },
                ),
                const SizedBox(height: 16),
                PasswordInputField(
                  controller: controller.confirmPasswordController,
                  label: 'Confirm Password',
                  isConfirmField: true,
                  isTablet: isTablet,
                  authController: controller,
                  onChanged: (value) {
                    controller.validateConfirmPassword(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNavigationButtons(isTablet),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker(bool isTablet) {
    return Column(
      children: [
        Obx(() => CircleAvatar(
              radius: isTablet ? 80.r : 60.r,
              backgroundColor: AppTheme.primarySwatch.shade100,
              backgroundImage: controller.pickedImage.value != null
                  ? FileImage(controller.pickedImage.value!)
                  : null,
              child: controller.pickedImage.value == null
                  ? Icon(
                      Icons.add_a_photo,
                      size: isTablet ? 40.r : 30.r,
                      color: AppTheme.primarySwatch,
                    )
                  : null,
            )),
        SizedBox(height: 16.h),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16.w,
          runSpacing: 8.h,
          children: [
            ModernButton(
              text: AppStrings.buttonTakePhoto,
              onPressed: controller.captureImage,
              isOutlined: true,
            ),
            ModernButton(
              text: AppStrings.buttonChoosePhoto,
              onPressed: controller.pickImage,
              isOutlined: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (controller.currentPage.value > 0)
          Expanded(
            child: ModernButton(
              text: AppStrings.buttonPrevious,
              onPressed: controller.previousPage,
              isOutlined: true,
            ),
          )
        else
          const Spacer(),
        SizedBox(width: 16.w),
        Expanded(
          child: ModernButton(
            text: controller.currentPage.value == 4
                ? AppStrings.buttonFinish
                : AppStrings.buttonNext,
            onPressed: () {
              if (controller.currentPage.value == 4) {
                controller.register();
              } else {
                controller.nextPage();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoPage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller.ageController,
                "Age",
                Icons.cake_outlined,
                isTablet,
              ),
              _buildGenderDropdown(isTablet),
              _buildTextField(
                controller.phoneNoController,
                "Phone",
                Icons.phone_outlined,
                isTablet,
              ),
              _buildDropdown(
                "Country",
                Icons.flag_outlined,
                countries,
                (value) {
                  controller.countryController.text = value;
                  controller.selectedCountry.value = value;
                },
                isTablet,
              ),
              _buildTextField(
                controller.cityController,
                "City",
                Icons.location_city_outlined,
                isTablet,
              ),
              _buildDropdown(
                "Nationality",
                Icons.public_outlined,
                nationalities,
                (value) {
                  controller.nationalityController.text = value;
                  controller.selectedNationality.value = value;
                },
                isTablet,
              ),
              _buildDropdown(
                "Education Level",
                Icons.school_outlined,
                educationLevels,
                (value) {
                  controller.educationController.text = value;
                  controller.selectedEducation.value = value;
                },
                isTablet,
              ),
              _buildDropdown(
                "Language",
                Icons.language_outlined,
                languages,
                (value) {
                  controller.languageSpokenController.text = value;
                  controller.selectedLanguage.value = value;
                },
                isTablet,
              ),
              _buildDropdown(
                "Religion",
                Icons.church_outlined,
                religion,
                (value) {
                  controller.religionController.text = value;
                  controller.selectedReligion.value = value;
                },
                isTablet,
              ),
              _buildDropdown(
                "Ethnicity",
                Icons.people_outline,
                ethnicities,
                (value) {
                  controller.ethnicityController.text = value;
                  controller.selectedEthnicity.value = value;
                },
                isTablet,
              ),
              _buildTextField(
                controller.profileHeadingController,
                "Profile Heading",
                Icons.text_fields_outlined,
                isTablet,
              ),
              const SizedBox(height: 32),
              _buildNavigationButtons(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearancePage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller.heightController,
                "Height (cm)",
                Icons.height_outlined,
                isTablet,
              ),
              _buildTextField(
                controller.weightController,
                "Weight (kg)",
                Icons.fitness_center_outlined,
                isTablet,
              ),
              _buildBodyTypeDropdown(isTablet),
              const SizedBox(height: 32),
              _buildNavigationButtons(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifestylePage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                "Drinking Habits",
                Icons.local_bar_outlined,
                drinkingHabits,
                (value) {
                  controller.drinkController.text = value;
                  controller.selectedDrink.value = value;
                },
                isTablet,
              ),
              _buildDropdown(
                "Smoking Habits",
                Icons.smoking_rooms_outlined,
                smokingHabits,
                (value) {
                  controller.smokeController.text = value;
                  controller.selectedSmoke.value = value;
                },
                isTablet,
              ),
              _buildDropdown(
                "Marital Status",
                Icons.people_outline,
                maritalStatuses,
                (value) {
                  controller.martialStatusController.text = value;
                  controller.selectedMaritalStatus.value = value;
                },
                isTablet,
              ),
              _buildCheckboxGroup(
                "Do you have children?",
                Icons.child_care_outlined,
                controller.childrenOptions,
                controller.childrenSelection,
                controller.updateChildrenOption,
                isTablet,
              ),
              if (controller.childrenSelection.value.isNotEmpty)
                _buildTextField(
                  controller.noOfChildrenController,
                  "Number of Children",
                  Icons.child_friendly_outlined,
                  isTablet,
                ),
              _buildDropdown(
                "Profession",
                Icons.work_outline,
                itJobs,
                (value) {
                  controller.professionController.text = value;
                  controller.selectedProfession.value = value;
                },
                isTablet,
              ),
              _buildDropdown(
                "Employment Status",
                Icons.business_center_outlined,
                employmentStatuses,
                (value) {
                  controller.employmentStatusController.text = value;
                  controller.selectedEmploymentStatus.value = value;
                },
                isTablet,
              ),
              _buildTextField(
                controller.incomeController,
                "Annual Income",
                Icons.attach_money_outlined,
                isTablet,
              ),
              _buildDropdown(
                "Living Situation",
                Icons.home_outlined,
                livingSituations,
                (value) {
                  controller.livingSituationController.text = value;
                  controller.selectedLivingSituation.value = value;
                },
                isTablet,
              ),
              _buildCheckboxGroup(
                "What's your relationship status?",
                Icons.favorite_outline,
                controller.relationshipOptions,
                controller.relationshipSelection,
                controller.updateRelationshipOption,
                isTablet,
              ),
              const SizedBox(height: 32),
              _buildNavigationButtons(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCareerPage(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: isTablet ? 800.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Career Information',
                style: TextStyle(
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primarySwatch,
                ),
              ),
              SizedBox(height: isTablet ? 30.0 : 20.0),
              _buildCareerGoalsSection(isTablet),
              SizedBox(height: isTablet ? 30.0 : 20.0),
              _buildSkillsSection(isTablet),
              SizedBox(height: isTablet ? 30.0 : 20.0),
              _buildWorkExperienceSection(isTablet),
              SizedBox(height: isTablet ? 30.0 : 20.0),
              _buildProjectsSection(isTablet),
              const SizedBox(height: 32),
              _buildNavigationButtons(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCareerGoalsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Career Goals',
          style: AppTheme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.careerGoalController,
          decoration: AppTheme.inputDecoration.copyWith(
            labelText: 'What are your career goals?',
            prefixIcon: const Icon(Icons.flag),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.targetPositionController,
          decoration: AppTheme.inputDecoration.copyWith(
            labelText: 'Target Position',
            prefixIcon: const Icon(Icons.work),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: AppTheme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.skillController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: 'Add a skill',
                  prefixIcon: const Icon(Icons.code),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ModernButton(
              text: 'Add',
              onPressed: () {
                if (controller.skillController.text.isNotEmpty) {
                  controller.selectedSkills
                      .add(controller.skillController.text);
                  controller.skillController.clear();
                }
              },
              isOutlined: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.selectedSkills
                  .map((skill) => Chip(
                        label: Text(skill),
                        onDeleted: () =>
                            controller.selectedSkills.remove(skill),
                        backgroundColor: AppTheme.primarySwatch.shade50,
                        labelStyle: TextStyle(color: AppTheme.primarySwatch),
                      ))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildWorkExperienceSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Work Experience',
              style: AppTheme.textTheme.titleLarge,
            ),
            ModernButton(
              text: 'Add Experience',
              onPressed: () => controller.showAddWorkExperienceDialog(isTablet),
              isOutlined: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => Column(
              children: controller.workExperiences
                  .map((exp) => _buildExperienceItem(exp, isTablet))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildExperienceItem(WorkExperience exp, bool isTablet) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp.title,
            style: AppTheme.textTheme.titleMedium,
          ),
          Text(
            exp.company,
            style: AppTheme.textTheme.bodyLarge,
          ),
          Text(
            '${exp.startDate} - ${exp.endDate ?? 'Present'}',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          if (exp.description != null) ...[
            const SizedBox(height: 8),
            Text(
              exp.description!,
              style: AppTheme.textTheme.bodyMedium,
            ),
          ],
          if (exp.technologies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exp.technologies
                  .map((tech) => Chip(
                        label: Text(tech),
                        backgroundColor: AppTheme.primarySwatch.shade50,
                        labelStyle: TextStyle(color: AppTheme.primarySwatch),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Projects',
              style: AppTheme.textTheme.titleLarge,
            ),
            ModernButton(
              text: 'Add Project',
              onPressed: () => controller.showAddProjectDialog(isTablet),
              isOutlined: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => Column(
              children: controller.projects
                  .map((project) => _buildProjectItem(project, isTablet))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildProjectItem(Project project, bool isTablet) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: AppTheme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: AppTheme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: project.technologies
                .map((tech) => Chip(
                      label: Text(tech),
                      backgroundColor: AppTheme.primarySwatch.shade50,
                      labelStyle: TextStyle(color: AppTheme.primarySwatch),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isTablet, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 15.0),
      child: TextField(
        controller: controller,
        decoration: AppTheme.inputDecoration.copyWith(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontSize: isTablet ? 16.0 : 14.0,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 13.0),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedGender.value.isNotEmpty
                ? controller.selectedGender.value
                : gender.first,
            onChanged: (value) {
              final selectedValue = value ?? gender.first;
              controller.genderController.text = selectedValue;
              controller.selectedGender.value = selectedValue;
            },
            items: gender.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            decoration: AppTheme.inputDecoration.copyWith(
              labelText: "Gender",
              prefixIcon: const Icon(Icons.person_outlined),
            ),
            isExpanded: true,
            menuMaxHeight: 200,
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            style: TextStyle(
              fontSize: isTablet ? 16.0 : 14.0,
              color: Colors.black87,
            ),
          )),
    );
  }

  Widget _buildBodyTypeDropdown(bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 13.0),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedBodyType.value.isNotEmpty
                ? controller.selectedBodyType.value
                : bodyTypes.first,
            onChanged: (value) {
              final selectedValue = value ?? bodyTypes.first;
              controller.bodyTypeController.text = selectedValue;
              controller.selectedBodyType.value = selectedValue;
            },
            items: bodyTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            decoration: AppTheme.inputDecoration.copyWith(
              labelText: "Body Type",
              prefixIcon: const Icon(Icons.accessibility_new_outlined),
            ),
            isExpanded: true,
            menuMaxHeight: 200,
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            style: TextStyle(
              fontSize: isTablet ? 16.0 : 14.0,
              color: Colors.black87,
            ),
          )),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    List<String> items,
    Function(String) onChanged,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 13.0),
      child: Obx(() {
        // Dropdown değerini belirle
        String? currentValue;

        // Her dropdown için uygun observable değişkeni kontrol et
        switch (label) {
          case "Country":
            currentValue = controller.selectedCountry.value.isNotEmpty
                ? controller.selectedCountry.value
                : items.first;
            break;
          case "Nationality":
            currentValue = controller.selectedNationality.value.isNotEmpty
                ? controller.selectedNationality.value
                : items.first;
            break;
          case "Education Level":
            currentValue = controller.selectedEducation.value.isNotEmpty
                ? controller.selectedEducation.value
                : items.first;
            break;
          case "Language":
            currentValue = controller.selectedLanguage.value.isNotEmpty
                ? controller.selectedLanguage.value
                : items.first;
            break;
          case "Religion":
            currentValue = controller.selectedReligion.value.isNotEmpty
                ? controller.selectedReligion.value
                : items.first;
            break;
          case "Ethnicity":
            currentValue = controller.selectedEthnicity.value.isNotEmpty
                ? controller.selectedEthnicity.value
                : items.first;
            break;
          case "Drinking Habits":
            currentValue = controller.selectedDrink.value.isNotEmpty
                ? controller.selectedDrink.value
                : items.first;
            break;
          case "Smoking Habits":
            currentValue = controller.selectedSmoke.value.isNotEmpty
                ? controller.selectedSmoke.value
                : items.first;
            break;
          case "Marital Status":
            currentValue = controller.selectedMaritalStatus.value.isNotEmpty
                ? controller.selectedMaritalStatus.value
                : items.first;
            break;
          case "Profession":
            currentValue = controller.selectedProfession.value.isNotEmpty
                ? controller.selectedProfession.value
                : items.first;
            break;
          case "Employment Status":
            currentValue = controller.selectedEmploymentStatus.value.isNotEmpty
                ? controller.selectedEmploymentStatus.value
                : items.first;
            break;
          case "Living Situation":
            currentValue = controller.selectedLivingSituation.value.isNotEmpty
                ? controller.selectedLivingSituation.value
                : items.first;
            break;
          default:
            currentValue = items.first;
        }

        return DropdownButtonFormField<String>(
          value: currentValue,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);

              // Dropdown değerini uygun observable değişkene ata
              switch (label) {
                case "Country":
                  controller.selectedCountry.value = value;
                  break;
                case "Nationality":
                  controller.selectedNationality.value = value;
                  break;
                case "Education Level":
                  controller.selectedEducation.value = value;
                  break;
                case "Language":
                  controller.selectedLanguage.value = value;
                  break;
                case "Religion":
                  controller.selectedReligion.value = value;
                  break;
                case "Ethnicity":
                  controller.selectedEthnicity.value = value;
                  break;
                case "Drinking Habits":
                  controller.selectedDrink.value = value;
                  break;
                case "Smoking Habits":
                  controller.selectedSmoke.value = value;
                  break;
                case "Marital Status":
                  controller.selectedMaritalStatus.value = value;
                  break;
                case "Profession":
                  controller.selectedProfession.value = value;
                  break;
                case "Employment Status":
                  controller.selectedEmploymentStatus.value = value;
                  break;
                case "Living Situation":
                  controller.selectedLivingSituation.value = value;
                  break;
              }
            }
          },
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          decoration: AppTheme.inputDecoration.copyWith(
            labelText: label,
            prefixIcon: Icon(icon),
          ),
          isExpanded: true,
          menuMaxHeight: 200,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down),
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            color: Colors.black87,
          ),
        );
      }),
    );
  }

  Widget _buildCheckboxGroup(
    String label,
    IconData icon,
    List<String> options,
    RxString selection,
    Function(String) onChanged,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primarySwatch),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...options.map((option) => Obx(() => CheckboxListTile(
                title: Text(option),
                value: selection.value == option,
                onChanged: (bool? value) {
                  if (value == true) {
                    onChanged(option);
                  }
                },
                activeColor: AppTheme.primarySwatch,
              ))),
        ],
      ),
    );
  }
}

class PasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isConfirmField;
  final Function(String) onChanged;
  final bool isTablet;
  final AuthController authController;

  const PasswordInputField({
    super.key,
    required this.controller,
    required this.label,
    this.isConfirmField = false,
    required this.onChanged,
    this.isTablet = false,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          // Şifre metnini observable değişkene ata
          if (!isConfirmField) {
            authController.passwordText.value = controller.text;
          }

          final strength = !isConfirmField
              ? PasswordValidator.validatePassword(
                  authController.passwordText.value)
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                obscureText: authController.obsPass.value,
                onChanged: (value) {
                  onChanged(value);
                  // Şifre değiştiğinde observable değişkeni güncelle
                  if (!isConfirmField) {
                    authController.passwordText.value = value;
                  }
                },
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: label,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      authController.obsPass.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => authController.obsPass.value =
                        !authController.obsPass.value,
                  ),
                ),
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                ),
              ),
              if (!isConfirmField && strength != null) ...[
                SizedBox(height: isTablet ? 16.h : 12.h),
                _buildPasswordStrengthIndicator(strength, isTablet),
                SizedBox(height: isTablet ? 16.h : 12.h),
                _buildPasswordRequirementsList(strength, isTablet),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(
      PasswordStrength strength, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.passwordStrength,
              style: TextStyle(
                fontSize: isTablet ? 14.0 : 12.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              strength.strengthText,
              style: TextStyle(
                fontSize: isTablet ? 14.0 : 12.0,
                fontWeight: FontWeight.bold,
                color: strength.color,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 8.h : 6.h),
        LinearProgressIndicator(
          value: strength.score / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(strength.color),
          minHeight: isTablet ? 8.0 : 6.0,
        ),
      ],
    );
  }

  Widget _buildPasswordRequirementsList(
      PasswordStrength strength, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.validatePasswordRequirements,
            style: TextStyle(
              fontSize: isTablet ? 14.0 : 12.0,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isTablet ? 12.h : 8.h),
          ...strength.requirements
              .map((req) => _buildRequirementItem(req, isTablet)),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(PasswordRequirement req, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8.h : 6.h),
      child: Row(
        children: [
          Container(
            width: isTablet ? 20.0 : 16.0,
            height: isTablet ? 20.0 : 16.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: req.isMet ? Colors.green : Colors.grey[300],
            ),
            child: Icon(
              req.isMet ? Icons.check : Icons.close,
              color: req.isMet ? Colors.white : Colors.grey[600],
              size: isTablet ? 12.0 : 10.0,
            ),
          ),
          SizedBox(width: isTablet ? 12.w : 8.w),
          Expanded(
            child: Text(
              req.description,
              style: TextStyle(
                fontSize: isTablet ? 13.0 : 11.0,
                color: req.isMet ? Colors.green[700] : Colors.grey[600],
                fontWeight: req.isMet ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final bool isTablet;
  final bool var1;
  final bool var2;
  final bool var3;
  final bool var4;
  final bool var5;

  const CustomProgressBar({
    super.key,
    required this.isTablet,
    required this.var1,
    required this.var2,
    required this.var3,
    required this.var4,
    required this.var5,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progress =
        [var1, var2, var3, var4, var5].where((element) => element).length;

    return Container(
      width: screenWidth,
      height: isTablet ? 36 : 24,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress / 5,
            child: Container(
              height: isTablet ? 18 : 12,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool value) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: value ? Colors.green : Colors.grey,
      ),
    );
  }
}

class CheckList extends StatelessWidget {
  final bool isTablet;
  final int index;
  CheckList({
    super.key,
    required this.isTablet,
    required this.index,
  });

  AuthController controller = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          controller.checks[index].value ? Icons.done : Icons.close,
          color: controller.checks[index].value ? Colors.green : Colors.red,
          size: isTablet ? 18 : 14,
        ),
        SizedBox(
          width: isTablet ? 12 : 5,
        ),
        Text(controller.textler[index],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 18 : 14,
              color: controller.checks[index].value ? Colors.green : Colors.red,
            ))
      ],
    );
  }
}

class SocialLinksSection extends StatelessWidget {
  final AuthController controller;
  final bool isTablet;

  const SocialLinksSection({
    super.key,
    required this.controller,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social Media Profiles',
            style: TextStyle(
              fontSize: isTablet ? 20.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: AppTheme.primarySwatch,
            ),
          ),
          SizedBox(height: 16),
          _buildSocialInput(
            controller: controller.instagramController,
            prefix: '@',
            icon: Icons.camera_alt,
            label: 'Instagram',
            color: Color(0xFFE4405F),
            placeholder: 'username',
          ),
        ],
      ),
    );
  }

  Widget _buildSocialInput({
    required TextEditingController controller,
    required String prefix,
    required IconData icon,
    required String label,
    required Color color,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: isTablet ? 24.0 : 20.0),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16.0 : 12.0,
                  vertical: isTablet ? 12.0 : 10.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(8)),
                  border:
                      Border(right: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Text(
                  prefix,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: isTablet ? 14.0 : 12.0,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: AppStrings.placeholderUsername,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16.0 : 12.0,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.content_paste, color: Colors.grey.shade600),
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    final url = data!.text!;
                    final username = _extractUsername(url, label);
                    if (username != null) {
                      controller.text = username;
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _extractUsername(String text, String platform) {
    switch (platform) {
      case 'Instagram':
        if (text.contains('instagram.com')) {
          final match = RegExp(r'instagram\.com/([^/]+)').firstMatch(text);
          return match?.group(1);
        }
        return text.replaceAll('@', '');
      default:
        return text;
    }
  }
}
