import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Model/rental_model.dart';
import 'package:security_rental/Screen/Widget/Common/loading_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:security_rental/Screen/Widget/Car/rental_card.dart';
import 'package:security_rental/Service/rental_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isLoading = false;
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Pending',
    'Approved',
    'ongoing',
    'Selesai',
    'Dibatalkan',
    'Ditolak'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRentals();
    });
  }

  Future<void> _loadRentals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Dalam aplikasi nyata, gunakan token dari authService
      await Provider.of<RentalService>(context, listen: false)
          .fetchRentals('Samid');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data riwayat pinjam: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Rental> _getFilteredRentals(List<Rental> rentals) {
    if (_selectedFilter == 'Semua') {
      return rentals
          .where((rental) =>
              rental.status == RentalStatus.pending ||
              rental.status == RentalStatus.approved ||
              rental.status == RentalStatus.onGoing ||
              rental.status == RentalStatus.completed ||
              rental.status == RentalStatus.cancelled ||
              rental.status == RentalStatus.rejected)
          .toList();
    } else if (_selectedFilter == "Pending") {
      return rentals
          .where((rental) => rental.status == RentalStatus.pending)
          .toList();
    } else if (_selectedFilter == "Approved") {
      return rentals
          .where((rental) => rental.status == RentalStatus.approved)
          .toList();
    } else if (_selectedFilter == "ongoing") {
      return rentals
          .where((rental) => rental.status == RentalStatus.onGoing)
          .toList();
    } else if (_selectedFilter == 'Selesai') {
      return rentals
          .where((rental) => rental.status == RentalStatus.completed)
          .toList();
    } else if (_selectedFilter == 'Dibatalkan') {
      return rentals
          .where((rental) => rental.status == RentalStatus.cancelled)
          .toList();
    } else if (_selectedFilter == 'Ditolak') {
      return rentals
          .where((rental) => rental.status == RentalStatus.rejected)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final rentalService = Provider.of<RentalService>(context);
    final rentals = rentalService.rentals;
    final filteredRentals = _getFilteredRentals(rentals);

    return _isLoading
        ? Center(child: LoadingWidget())
        : Column(
            children: [
              // Statistics
              SizedBox(
                height: 48.h,
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Peminjaman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatItem(
                          context,
                          count: rentals
                              .where((rental) =>
                                  rental.status == RentalStatus.completed)
                              .length,
                          label: 'Selesai',
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                        ),
                        _buildStatItem(
                          context,
                          count: rentals
                              .where((rental) =>
                                  rental.status == RentalStatus.cancelled)
                              .length,
                          label: 'Dibatalkan',
                          color: Colors.orange,
                          icon: Icons.cancel_outlined,
                        ),
                        _buildStatItem(
                          context,
                          count: rentals
                              .where((rental) =>
                                  rental.status == RentalStatus.rejected)
                              .length,
                          label: 'Ditolak',
                          color: Colors.red,
                          icon: Icons.highlight_off,
                        ),
                      ],
                    ),
                    if (rentals
                        .where(
                            (rental) => rental.status == RentalStatus.completed)
                        .isNotEmpty)
                      ...[],
                  ],
                ),
              ),

              // Filter options
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filterOptions.map((filter) {
                          final isSelected = filter == _selectedFilter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                }
                              },
                              selectedColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Rental List
              Expanded(
                child: filteredRentals.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadRentals,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.history,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Tidak ada riwayat Peminjaman',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Riwayat pinjam Anda akan muncul di sini',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRentals,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 64.h),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredRentals.length,
                            itemBuilder: (context, index) {
                              final rental = filteredRentals[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: RentalCard(rental: rental),
                              );
                            },
                          ),
                        ),
                      ),
              ),
            ],
          );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required int count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
