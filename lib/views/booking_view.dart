import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../viewmodels/app_state.dart';
import '../viewmodels/booking_viewmodel.dart';
import 'services_view.dart';

class BookingView extends StatefulWidget {
  final bool isFromNavBar;
  const BookingView({super.key, this.isFromNavBar = false});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final BookingViewModel _vm = BookingViewModel();
  final _regCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  bool isUploading = false;

  List<DateTime> get next7Days {
    return List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    _vm.fetchBookedSlots();
    _vm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _regCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
        leading: widget.isFromNavBar
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GeometricBackground()),
          AnimatedBuilder(
            animation: _vm,
            builder: (context, child) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Select date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // DATES
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: next7Days.length,
                      itemBuilder: (context, index) {
                        DateTime date = next7Days[index];
                        String dateStr = DateFormat('dd MMM').format(date);
                        String dbDateStr = DateFormat(
                          'yyyy-MM-dd',
                        ).format(date);

                        bool isSelected = _vm.selectedDate == dbDateStr;
                        bool isFull = _vm.isDateFullyBooked(dbDateStr);

                        return GestureDetector(
                          onTap: isFull
                              ? null
                              : () {
                                  // ONLY update the ViewModel
                                  _vm.selectDate(dateStr);
                                },
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isFull
                                  ? Colors.grey.shade300
                                  : (isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: isSelected && !isFull
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryBlue.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    color: isFull
                                        ? Colors.grey.shade500
                                        : (isSelected
                                              ? Colors.white70
                                              : Colors.grey),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    color: isFull
                                        ? Colors.grey.shade500
                                        : (isSelected
                                              ? Colors.white
                                              : AppColors.navy),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Available Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // TIMES
                  if (_vm.selectedDate != null)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _vm.allTimeSlots.map((time) {
                        String dbDateStr = _vm.selectedDate!;
                        bool isSelected = _vm.selectedTime == time;
                        bool isBooked = _vm.isTimeBooked(dbDateStr, time);

                        return GestureDetector(
                          onTap: isBooked
                              ? null
                              : () {
                                  // ONLY update the ViewModel
                                  _vm.selectTime(time);
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? Colors.grey.shade300
                                  : (isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                color: isBooked
                                    ? Colors.grey.shade500
                                    : (isSelected
                                          ? Colors.white
                                          : AppColors.navy),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text(
                      "Please select a date first.",
                      style: TextStyle(color: Colors.grey),
                    ),

                  const SizedBox(height: 20),
                  const Text(
                    'Car Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _vm.selectedCarType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _vm.carTypes.keys
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null)
                        setState(() {
                          _vm.selectedCarType = val;
                        });
                    },
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _regCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Car Registration (Required)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _vm.pickImage(),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryBlue,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _vm.carImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _vm.carImageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primaryBlue,
                                  size: 40,
                                ),
                                Text(
                                  'Tap to Upload Car Image (Required)',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    onChanged: (val) => _vm.valuablesComment = val,
                    decoration: InputDecoration(
                      labelText: 'Valuables in car (Optional)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isUploading
                          ? null
                          : () async {
                              // Check if ALL fields are filled
                              if (_regCtrl.text.isNotEmpty &&
                                  _vm.carImageBytes != null &&
                                  _vm.selectedDate != null &&
                                  _vm.selectedTime != null) {
                                setState(() => isUploading = true);

                                // 1. Double booking check
                                bool isAvailable = await _vm
                                    .checkIfSlotStillAvailable();

                                if (!isAvailable) {
                                  if (!mounted) return;
                                  setState(() => isUploading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Sorry, someone else just booked this time! Please pick another.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  _vm.fetchBookedSlots();
                                  return;
                                }

                                // 2. Upload Image
                                String? imageUrl = await _vm.uploadImage();

                                if (!mounted) return;
                                setState(() => isUploading = false);

                                if (imageUrl != null) {
                                  double multiplier =
                                      _vm.carTypes[_vm.selectedCarType] ?? 1.0;

                                  // 3. SAVE EVERYTHING TO APPSTATE RIGHT NOW (AT THE VERY END)
                                  final appState = Provider.of<AppState>(
                                    context,
                                    listen: false,
                                  );
                                  appState.selectedDate = _vm.selectedDate;
                                  appState.selectedTime = _vm.selectedTime;
                                  appState.selectedCarType = _vm.selectedCarType;
                                  appState.carRegistration = _regCtrl.text;
                                  appState.carImageUrl = imageUrl;
                                  appState.carMultiplier = multiplier;
                                  appState.valuablesComment = _commentCtrl.text;
                                  appState.notifyListeners();

                                  // 4. Go to Services
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ServicesView(
                                        carMultiplier: multiplier,
                                        carImageUrl: imageUrl,
                                        carRegistration: _regCtrl.text,
                                        carModel: _vm.selectedCarType,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Image upload failed. Try again.',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a date, time, fill in registration, and upload an image.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      child: isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
