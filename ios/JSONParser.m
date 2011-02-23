//
//  JSONParser.m
//  Shuttle-Tracker
//
//  Created by Brendon Justin on 2/12/11.
//  Copyright 2011 Brendon Justin. All rights reserved.
//

#import "JSONParser.h"
#import "TouchJSON/Extensions/NSDictionary_JSONExtensions.h"
#import "EtaWrapper.h"


@implementation JSONParser

@synthesize vehicles;
@synthesize etas;


- (id)init {
    [self initWithUrl:[NSURL URLWithString:@"http://www.abstractedsheep.com/~ashulgach/data_service.php?action=get_shuttle_positions"]];
    
    return self;
}


//  Init and parse JSON from some specified URL
- (id)initWithUrl:(NSURL *)url {
    if ((self = [super init])) {
        jsonUrl = url;
        [jsonUrl retain];
        
    }
    
    return self;
}


- (BOOL)parse {
    return [self parseShuttles];
}


//  Parse the shuttle data we will get from http://www.abstractedsheep.com/~ashulgach/data_service.php?action=get_shuttle_positions
- (BOOL)parseShuttles {
    NSError *theError = nil;
    NSString *jsonString = [NSString stringWithContentsOfURL:jsonUrl encoding:NSUTF8StringEncoding error:&theError];
    NSDictionary *jsonDict = nil;
    
    [vehicles release];
    
    vehicles = [[NSMutableArray alloc] init];
    
    if (theError) {
        NSLog(@"Error retrieving JSON data");
        
        return NO;
    } else {
        if (jsonString) {
            jsonDict = [NSDictionary dictionaryWithJSONString:jsonString error:&theError];
        } else {
            jsonDict = nil;
        }
        
//        NSLog(@"Dict: %@", jsonDict);
        
        for (NSDictionary *dict in jsonDict) {
            JSONVehicle *vehicle = [[JSONVehicle alloc] init];
            
            CLLocationCoordinate2D coordinate;
            
            for (NSString *string in dict) {
                if ([string isEqualToString:@"shuttle_id"]) {
                    vehicle.name = [dict objectForKey:string];
                } else if ([string isEqualToString:@"latitude"]) {
                    coordinate.latitude = [[dict objectForKey:string] floatValue];
                } else if ([string isEqualToString:@"longitude"]) {
                    coordinate.longitude = [[dict objectForKey:string] floatValue];
                } else if ([string isEqualToString:@"heading"]) {
                    vehicle.heading = [[dict objectForKey:string] intValue];
                }
            }
            
            vehicle.coordinate = coordinate;
            
            [vehicles addObject:vehicle];
            [vehicle release];
        }
        /*
         Only for http://nagasoftworks.com/ShuttleTracker/shuttleOutputData.txt
         
        //  Iterate through the items found, create vehicles, set their locations, and add them to the vehicles array
        for (NSString *string in jsonDict) {
            JSONVehicle *vehicle = [[JSONVehicle alloc] init];
            vehicle.name = string;
            vehicle.description = @"lol";
            
            NSArray *coordinates = [[jsonDict objectForKey:string] objectsForKeys:[NSArray arrayWithObjects:@"Latitude", @"Longitude", nil] notFoundMarker:[NSNull null]];
            
            vehicle.coordinate = CLLocationCoordinate2DMake([[coordinates objectAtIndex:0] doubleValue], [[coordinates objectAtIndex:1] doubleValue]);
            
            [vehicles addObject:vehicle];
        }
         */
        
        return YES;
    }
    
    return NO;
}


//  Parse the ETAs we will get, as formatted at http://abstractedsheep.com/~ashulgach/data_service.php?action=get_all_eta
- (BOOL)parseEtas {
    NSError *theError = nil;
    NSString *jsonString = [NSString stringWithContentsOfURL:jsonUrl encoding:NSUTF8StringEncoding error:&theError];
    NSDictionary *jsonDict = nil;
    
    [etas release];
    
    etas = [[NSMutableArray alloc] init];
    
    if (theError) {
        NSLog(@"Error retrieving JSON data");
        
        return NO;
    } else {
        if (jsonString) {
            jsonDict = [NSDictionary dictionaryWithJSONString:jsonString error:&theError];
        } else {
            jsonDict = nil;
        }
        
        //        NSLog(@"Dict: %@", jsonDict);
        
        for (NSDictionary *dict in jsonDict) {
            EtaWrapper *eta = [[EtaWrapper alloc] init];
            
            for (NSString *string in dict) {
                if ([string isEqualToString:@"shuttle_id"]) {
                    eta.shuttleId = [dict objectForKey:string];
                } else if ([string isEqualToString:@"stop_id"]) {
                    eta.stopId = [dict objectForKey:string];
                } else if ([string isEqualToString:@"eta"]) {
                    eta.eta = [NSDate dateWithTimeIntervalSinceNow:[[dict objectForKey:string] floatValue]/1000.0f];
                } else if ([string isEqualToString:@"route"]) {
                    eta.route = [[dict objectForKey:string] intValue];
                }
            }
            
            [etas addObject:eta];
            [eta release];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)dealloc {
    [super dealloc];
}


@end


@implementation JSONPlacemark

@synthesize name;
@synthesize description;
@synthesize coordinate;
@synthesize annotationView;

- (id)init {
    if ((self = [super init])) {
        name = nil;
        description = nil;
        
        annotationView = nil;
    }
    
    return self;
}

- (NSString *)title {
	return name;
}

- (NSString *)subtitle {
	return description;
}


@end

@implementation JSONStop


- (id)init {
    if ((self = [super init])) {
        name = nil;
        description = nil;
        
        annotationView = nil;
    }
    
    return self;
}

@end


@implementation JSONVehicle

@synthesize ETAs;
@synthesize heading;


- (id)init {
    if ((self = [super init])) {
        name = nil;
        description = nil;
        ETAs = nil;
        annotationView = nil;
        
        heading = 0;
    }

    return self;
}


@end
