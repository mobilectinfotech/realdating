import 'common_import.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final int? maxLines;
  final int? maxLength;

  final ValueChanged<String>? onChanged;
  final Function(bool)? focusStatusChangeHandler;

  const AppTextField(
      {super.key, required this.controller, this.hintText, this.label, this.maxLines, this.onChanged, this.icon, this.maxLength, this.focusStatusChangeHandler});

  @override
  Widget build(BuildContext context) {
    return InputField(
        controller: controller,
        hintText: hintText,
        icon: icon,
        label: label,
        maxLines: maxLines,
        onChanged: onChanged,
        maxLength: maxLength,
        backgroundColor: AppColorConstants.cardColor.darken(0.02),
        cornerRadius: 10,
        iconColor: AppColorConstants.iconColor,
        focusStatusChangeHandler: focusStatusChangeHandler);
  }
}

class AppPasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;
  final ValueChanged<String> onChanged;

  const AppPasswordTextField({super.key, required this.controller, required this.onChanged, this.hintText, this.icon});

  @override
  Widget build(BuildContext context) {
    return PasswordField(
      controller: controller,
      hintText: hintText,
      icon: icon,
      backgroundColor: AppColorConstants.cardColor,
      cornerRadius: 10,
      iconColor: AppColorConstants.iconColor,
      onChanged: onChanged,
    );
  }
}

class AppMobileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final String? countryCodeText;

  final ValueChanged<String>? countryCodeValueChanged;
  final ValueChanged<String>? onChanged;

  const AppMobileTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.label,
    this.icon,
    this.countryCodeText,
    this.countryCodeValueChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedInputMobileNumberField(
      controller: controller,
      hintText: hintText,
      countryCodeText: countryCodeText,
      countrycodeValueChanged: countryCodeValueChanged,
      label: label,
      backgroundColor: AppColorConstants.cardColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 10,
      onChanged: onChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}

class AppDateTextField extends StatelessWidget {
  final String? hintText;
  final String? defaultText;

  final ThemeIcon? icon;
  final String? label;
  final String? countryCodeText;

  final ValueChanged<TimeOfDay>? onChanged;

  const AppDateTextField({
    super.key,
    this.defaultText,
    this.hintText,
    this.label,
    this.icon,
    this.countryCodeText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedInputDateField(
      defaultText: defaultText,
      hintText: hintText,
      label: label,
      backgroundColor: AppColorConstants.cardColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 5,
      onChanged: onChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}

class AppDateTimeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final String? countryCodeText;

  final ValueChanged<DateTime>? onChanged;
  final DateTime? minDate;
  final DateTime? maxDate;

  const AppDateTimeTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.label,
    this.icon,
    this.countryCodeText,
    this.onChanged,
    this.minDate,
    this.maxDate,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedInputDateTimeField(
      controller: controller,
      minDate: minDate,
      maxDate: maxDate,
      hintText: hintText,
      label: label,
      backgroundColor: AppColorConstants.cardColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 10,
      onChanged: onChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}

class AppPriceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final String? currency;

  final ValueChanged<String>? currencyValueChanged;
  final ValueChanged<String>? onChanged;

  const AppPriceTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.label,
    this.icon,
    this.currency,
    this.currencyValueChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedInputPriceField(
      controller: controller,
      hintText: hintText,
      currency: currency,
      disable: true,
      label: label,
      backgroundColor: AppColorConstants.cardColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 10,
      onChanged: onChanged,
      currencyValueChanged: currencyValueChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}

class AppDropdownField extends StatelessWidget {
  final String? hintText;
  final ThemeIcon? icon;
  final String? label;
  final String? value;

  final ValueChanged<String> onChanged;
  final List<String> options;

  const AppDropdownField({super.key, this.hintText, this.label, this.icon, this.value, required this.onChanged, required this.options});

  @override
  Widget build(BuildContext context) {
    return RoundedDropdownField(
      options: options,
      hintText: hintText,
      label: label,
      value: value,
      backgroundColor: AppColorConstants.cardColor,
      textStyle: TextStyle(fontSize: FontSizes.h6),
      cornerRadius: 10,
      onChanged: onChanged,
      iconColor: AppColorConstants.iconColor,
    );
  }
}
