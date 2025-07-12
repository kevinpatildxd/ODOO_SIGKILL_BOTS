class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateQuestionTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }

    if (value.length < 10) {
      return 'Title must be at least 10 characters long';
    }

    return null;
  }

  static String? validateQuestionDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    if (value.length < 20) {
      return 'Description must be at least 20 characters long';
    }

    return null;
  }
  
  // Validate password with strong criteria
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  // Validate password and confirm password match
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // Validate URL
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$'
    );
    
    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    final phonePattern = RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!phonePattern.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // Validate text length within range
  static String? validateTextLength(String? value, {
    required String fieldName,
    int minLength = 0,
    int maxLength = 1000,
    bool isRequired = true,
  }) {
    if (value == null || value.isEmpty) {
      if (isRequired) {
        return '$fieldName is required';
      }
      return null;
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    
    return null;
  }
  
  // Validate if value is a number
  static String? validateNumber(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Number is optional
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    
    return null;
  }
}
