#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSItemProvider (TypedLoading)

- (void)lc_loadURLForTypeIdentifier:(NSString *)typeIdentifier
                            options:(nullable NSDictionary *)options
                  completionHandler:(void (^)(NSURL * _Nullable, NSError * _Nullable))completionHandler
    NS_SWIFT_NAME(lc_loadURL(forTypeIdentifier:options:completionHandler:));

- (void)lc_loadStringForTypeIdentifier:(NSString *)typeIdentifier
                               options:(nullable NSDictionary *)options
                     completionHandler:(void (^)(NSString * _Nullable, NSError * _Nullable))completionHandler
    NS_SWIFT_NAME(lc_loadString(forTypeIdentifier:options:completionHandler:));

@end

NS_ASSUME_NONNULL_END
