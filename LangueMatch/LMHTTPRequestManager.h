#import <AFNetworking/AFNetworking.h>

@interface LMHTTPRequestManager : AFHTTPRequestOperationManager

+(LMHTTPRequestManager *)sharedClient;

-(NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters;
-(NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate;

@end
