# InkWiz

Mobile App to convert handwritten text to editable text.

## Working

1. This application pick an image from camera/gallery.

2. Upload the image on tmpfiles using post api.

3. Then by using headless browser, pass the image url to the gooogle lens and extract text by scraping webpage of google lens.

## Plugin Used

1. Image Picker

2. Http

3. Flutter InAppWebView

## How to run project

# Step1: Clone the project
    git clone https://github.com/badiul6/InkWiz.git
    
# Step2: Install the dependencies
    flutter pub get

# Step3: Run the project
    flutter run

