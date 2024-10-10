# Impulsum App

## Overview
`Impulsum` is an iOS application built using MVVM architecture, Combine, and SwiftUI. This project demonstrates a clean and scalable approach to iOS development with modern Swift paradigms and SOLID principles.

## Project Setup

### Requirements
- Xcode 12.0+
- Swift 5.3+
- XcodeGen
- Cocoapods
- Postman
- Mockoon

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/Impulsum-id/Impulsum-App.git
   cd Impulsum-App

2. **Install XcodeGen:**
    ```sh
    brew install xcodegen

3. **Generate the Xcode project:**
    ```sh
    make generate_project
   ```

4. **Download API Collection here**
    TBA

### Technologies Used
- SwiftUI: For building the user interface.
- UIKIT: For building the user interface.
- Combine: For managing state and data flow.
- MVVM: Model-View-ViewModel architecture for separation of concerns.
- XcodeGen: For generating and managing the Xcode project configuration.
- Postman: For API documentation
- Mockoon: For mocking API response

### Third party
- Netfox: For network logging

### Contribution
Feel free to submit pull requests or open issues to help improve the project.

### License
This project is licensed under the MIT License. See the LICENSE file for more information.

Impulsum


# Semantic Guideline

### Types
- `feat` — new feature for the user
- `fix` — bug fix for the user
- `docs` — documentation changes
- `style` — formatting, missing semi colons, etc.
- `refactor` — refactoring production code
- `test` — adding missing tests, refactoring tests
- `chore` — updating grunt tasks, nothing that an external user would see

<br>

## Branch Names
### Format
```
<type>/<task_description>
```

### Example
```
docs/setup-instructions
feat/user-authentication
```

<br>

## Commit Messages
### Format
```
<type>(<optional scope>): <description>
```

### Example
```
feat: add login page
fix(button): logout user
```

<br>

## Pull Requests (Title)
### Format
```
<type>(<optional scope>): <brief description>
```

### Example
```
feat: add user authentication
fix(api): resolve 404 error on user fetch
docs: update README with setup instructions
```

<br>

## Pull Requests (Description)
### Format
```
## Summary
A brief description of the changes made.

## Changes Made
* Bullet point list of changes made

## Screenshots (if applicable)
Include screenshots of the changes in action, if applicable.
```

### Example
```
## Summary
Added user authentication feature to allow users to securely log in and access their accounts.

## Changes Made
* Created login and registration forms
* Integrated authentication API
* Added JWT token handling
* Updated navigation to reflect authentication state

## Screenshots (if applicable)
```
