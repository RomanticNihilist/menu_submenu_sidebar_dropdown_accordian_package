import 'package:flutter/material.dart';
import 'string_to_widget_map.dart';


class MenuItem {
  final String title;
  final IconData icon;
  final List<MenuItem>? subItems;
  final void Function()? onTap;

  MenuItem({
    required this.title,
    required this.icon,
    this.subItems,
    this.onTap,
  });

  MenuItem.withSubItem({
    required this.title,
    required this.icon,
    required this.subItems,
    this.onTap,
  });
}


class MenuWithSubMenu extends StatefulWidget {
  final ColorScheme colorScheme;
  final List<MenuItem> menuItems;
  final ThemeMode themeMode;
  final Function(bool) updateTheme;
  final Function(ColorScheme) updateColorScheme;
  const MenuWithSubMenu(
      {
        super.key,
        required this.colorScheme,
        required this.themeMode,
        required this.menuItems,
        required this.updateTheme,
        required this.updateColorScheme,
      }
      );

  @override
  State<MenuWithSubMenu> createState() => _MenuWithSubMenuState();
}

class _MenuWithSubMenuState extends State<MenuWithSubMenu> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: widget.menuItems.map((menuItem) {
            if (menuItem.subItems != null && menuItem.subItems!.isNotEmpty) {
              return Card(
                child: ExpansionTile(
                  title: Text(menuItem.title),
                  leading: Icon(menuItem.icon),
                  children: menuItem.subItems!.map((subItem) {
                    return ListTile(
                      title: Text(subItem.title),
                      trailing: Icon(subItem.icon),
                      onTap: () {
                        Navigator.pop(context);
                        if (subItem.onTap != null) {
                          // subItem.onTap!();
                          //widget.onMenuItemSelected();
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            } else {
              return Card(
                child: ListTile(
                    title: Text(menuItem.title),
                    leading: Icon(menuItem.icon),
                    onTap: () {
                      openMenuSubmenuWidget(
                          menuItem,
                          context,
                          widget.colorScheme,
                          widget.themeMode,
                          widget.updateTheme,
                          widget.updateColorScheme,
                          menuItems
                      );
                    }
                ),
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}

void openMenuSubmenuWidget(MenuItem menuItem, BuildContext context, ColorScheme colorScheme, ThemeMode themeMode, Function(bool) updateTheme, Function(ColorScheme) updateColorScheme, List<MenuItem> menuItems){
  String convertToCamelCase(String input) {
    List<String> words = input.split(' ');
    for (int i = 1; i < words.length; i++) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
    return words.join('');
  }

  String widgetName = convertToCamelCase(menuItem.title);
  Navigator.pop(context);
  StringToWidgetMap createMap = StringToWidgetMap(
    colorScheme: colorScheme,
    themeMode: themeMode,
    updateColorScheme: updateColorScheme,
    updateTheme: updateTheme,
    menuItems: menuItems,
  );
  if (createMap.widgetMap.containsKey(widgetName)) {
    Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => createMap.widgetMap[widgetName]!(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start from the right
            const end = Offset.zero; // End at the original position
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        )
    );
  } else {
    // Handle case where widget is not found
    print('Widget not found: $widgetName');
  }
}
