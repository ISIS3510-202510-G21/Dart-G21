import 'package:flutter/material.dart';
import '../../core/colors.dart';

class BarCategories extends StatelessWidget{
    final List<String> categories;

    //colors of the buttons
    List<Color> colors=[
      AppColors.buttonRed,AppColors.buttonOrange,AppColors.buttonGreen,
      AppColors.buttonLightBlue, AppColors.buttonDarkBlue,
      AppColors.buttonPurple
    ];

     BarCategories({
      Key? key,
      required this.categories,
    }) : super(key: key);

    @override
    Widget build(BuildContext context){
      return SizedBox(
        height: 41,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.asMap().entries.map((entry) {
              int index = entry.key;
              String texto = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () {} ,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors[index % colors.length],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    texto,
                    style: const TextStyle(color: AppColors.primary, fontSize: 15),
                  ),
                ),
              );
            }).toList(),

          ),
        ),
      );
    }
}