#import "NSItemProvider+TypedLoading.h"

@implementation NSItemProvider (TypedLoading)

- (void)lc_loadURLForTypeIdentifier:(NSString *)typeIdentifier
                            options:(NSDictionary *)options
                  completionHandler:(void (^)(NSURL *, NSError *))completionHandler {
    [self loadItemForTypeIdentifier:typeIdentifier options:options completionHandler:completionHandler];
}

- (void)lc_loadStringForTypeIdentifier:(NSString *)typeIdentifier
                               options:(NSDictionary *)options
                     completionHandler:(void (^)(NSString *, NSError *))completionHandler {
    [self loadItemForTypeIdentifier:typeIdentifier options:options completionHandler:completionHandler];
}

@end
