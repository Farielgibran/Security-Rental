import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Service/car_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarFilter extends StatelessWidget {
  final String selectedType;
  final Function(String) onChanged;

  const CarFilter({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final carService = Provider.of<CarService>(context, listen: false);
    final types = carService.carTypes;

    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = type == selectedType;

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                type,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged(type);
                }
              },
              backgroundColor:
                  Theme.of(context).colorScheme.onPrimary?.withOpacity(0.24),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}
