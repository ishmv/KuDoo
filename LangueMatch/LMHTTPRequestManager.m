#import "LMHTTPRequestManager.h"
#import <AFNetworking/AFNetworking.h>
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>

NSString *const kLMParseAPIBaseURLString = @"https://api.parse.com/1/";
NSString *const kRestAPIKey = @"mdP6huf2zF4TPEv4uneXKEKeJYelUhbMSKLN8uMV";

@interface LMHTTPRequestManager()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;

@end

@implementation LMHTTPRequestManager : AFHTTPRequestOperationManager

+(LMHTTPRequestManager *)sharedClient
{
    static LMHTTPRequestManager *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[LMHTTPRequestManager alloc] initWithBaseURL:[NSURL URLWithString:kLMParseAPIBaseURLString]];
    });
    
    return sharedClient;
}

-(instancetype)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL: url]) {
        [self.requestSerializer setValue:@"DNQ6uRHpKqC6kPHfYo1coL5P5xoGNMUw9w4KJEyz" forHTTPHeaderField:@"X-Parse-Application-Id"];
        [self.requestSerializer setValue:kRestAPIKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0;
        
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
        self.responseSerializer = serializer;
    }
    return self;
}


-(NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request;
    request = [self GETRequestForClass:className parameters:parameters];
    return request;
}

-(NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate
{
    NSMutableURLRequest *request = nil;
    NSDictionary *parameters = nil;
    
    if (updatedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'999Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        NSString *jsonString = [NSString stringWithFormat:@"{\"updatedAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"%@\"}}}",
                                [dateFormatter stringFromDate:updatedDate]];
        
        parameters = [NSDictionary dictionaryWithObject:jsonString forKey:@"where"];
    }
    
    request = [self GETRequestForClass:className parameters:parameters];
    return request;
}

@end
