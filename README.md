## Sample Flutter App ##

## Build Protobuf ##

It's required you to have a unix like platform or at least a platform that support run make command if you will to use the predefine command to generate protobuf.

To generate protobuf code run command `make genproto`, then start the fullter app with `flutter run`.

## Key features ##

- Use Custom Codec for Rich communication between flutter and native platform. The call from dart to native platform support passing protobuf object and method identifier as enum instead. On top of standard mesage, the custom codec can response with protobuf as well.
- Load local picture from native platform into Flutter GridView.
- Display some sensitive metadata and the ability to remove sensitive metadata.

## Known Issues ##

- Low quality of thumbnail image render with ui.Codec on iOS and iOS simulator. The same bytes data seem to render pretty fine on Swift native app. Investigation probably needed.
- When View Full Photo on iOS simulator the drag interraction on the photo is lagged. There probably an issue with iOS simulator. Similar issue can be found [here](https://github.com/flutter/flutter/issues/6135).
- When open Full Photo page from gridview using Material Route, the main page also is refreshed and also it happen when return from Full Photo page.

## Limitation ##

- Although the picture was loading from local device, the data need to pass from native plafrom to dart using asynchronouse execution which cause the deplay on each photo thumbnail rendering.
- Plugin, as method call and returned result support protobuf message there are a fews limitation on each platform and language:

    1. On iOS, returned result need to be wrapped inside any object name `ValueWrapper` as Flutter use Objective-C to implemented core framework on iOS. The result object passed to Objective-C then forward back to Swift custom codec `BufferWrite`, the object receive by Swift is losing it's runtime type and leading to an issue where we cannot check the type of the value that's being sent. To solve the issue, the result object must wrapped inside `ValueWrapper` and then at Swift side the `BufferWriter` will unwrap and use the result value object to check the type at runtime.
    2. Kotlin/Java and Dart generic type erasure prevent the plugin from create an instance of protobuf arguments when decoding method call. To solve this issue we need the provide a simple funtion where we can define which Protobuf message is represented by the bytes array data.

## Improvement ##

- On iOS devices, the plugin is using PhotoKits to load photo from local devices. As the photo on iOS support revision, the deletion of sensitve data will not permanent. To delete it permanently, we need to create a copy of the same photo without any metadata and finally delete the original photo or delete original revision of the photo.

## Cross-Platform ##

Flutter was mean to be cross platform build, one code based for all platform, however when the feaures of your app is relied on Native Platform's API, there might be a corner case where you have to main different code for different platform.

- Maintain image cache, the transfering data between flutter and native platform was perfrom under asynchronoze task which cause a bit of deplay to render multiple thumbnails. To improve the rendering time, an image cache directly on flutter is required as it can immediately read the raw decoded bytes data and render it with image widget. However as iOS PhotoKits has a build-in cache, this mean we have 2 components that cache the same image. So to avoid this issue we need to disable Flutter cache when the code is running on iOS devices.
