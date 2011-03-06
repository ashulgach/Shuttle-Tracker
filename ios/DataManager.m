//
//  EtaManager.m
//  Shuttle-Tracker
//
//  Created by Brendon Justin on 2/20/11.
//  Copyright 2011 Brendon Justin. All rights reserved.
//

#import "DataManager.h"
#import "EtaWrapper.h"


@interface DataManager()
- (void)loadFromKml;
- (void)routeKmlLoaded;
- (void)updateVehicleData;
- (void)vehicleJsonRefresh;
- (void)updateEtaData;
- (void)etaJsonRefresh;

@end

@implementation DataManager


@synthesize routes;
@synthesize stops;
@synthesize vehicles;
@synthesize etas;
@synthesize eastEtas;
@synthesize westEtas;
@synthesize timeDisplayFormatter;


- (id)init {
    if ((self = [super init])) {
        routes = nil;
        stops = nil;
        
        eastEtas = 0;
        westEtas = 0;
        
        //  shuttleJSONUrl = [NSURL URLWithString:@"http://nagasoftworks.com/ShuttleTracker/shuttleOutputData.txt"];
        shuttleJsonUrl = [NSURL URLWithString:@"http://www.abstractedsheep.com/~ashulgach/data_service.php?action=get_shuttle_positions"];
        vehiclesJsonParser = [[JSONParser alloc] initWithUrl:shuttleJsonUrl];
        
        etasJsonUrl = [NSURL URLWithString:@"http://www.abstractedsheep.com/~ashulgach/data_service.php?action=get_all_eta"];
        etasJsonParser = [[JSONParser alloc] initWithUrl:etasJsonUrl];
        
        vehicles = [[NSMutableArray alloc] init];
		
		loadVehicleJsonQueue = NULL;
		loadEtaJsonQueue = NULL;
    }
    
    return self;
}

- (void)dealloc {
    if (routeKmlParser) {
        [routeKmlParser release];
    }
    
    if (vehiclesKmlParser) {
        [vehiclesKmlParser release];
    }
    
    if (vehiclesJsonParser) {
        [vehiclesJsonParser release];
    }
    
    if (etasJsonParser) {
        [etasJsonParser release];
    }
    
    [shuttleJsonUrl release];
    [etasJsonUrl release];
    
    if (routes) {
        [routes release];
    }
    if (stops) {
        [stops release];
    }
    
    [vehicles release];
    
    if (etas) {
        [etas release];
    }
    
    [super dealloc];
}

- (void)loadRoutesAndStops {
    [self loadFromKml];
}

- (void)loadFromKml {
    //  Use the local copy of the routes/stops KML file
    NSURL *routeKmlUrl = [[NSBundle mainBundle] URLForResource:@"netlink" withExtension:@"kml"];
    
    routeKmlParser = [[KMLParser alloc] initWithContentsOfUrl:routeKmlUrl];
    [routeKmlParser parse];
    [self routeKmlLoaded];
}

//  TODO: Remove this or adjust it to be appropriate for DataManager. Taken from MapViewController.
- (void)routeKmlLoaded {
    
    routes = [routeKmlParser routes];
    [routes retain];
    
    stops = [routeKmlParser stops];
    [stops retain];
    
}


- (void)updateData {
    [self updateVehicleData];
    [self updateEtaData];
}


- (void)updateVehicleData {
    
	if (!loadVehicleJsonQueue) {
		loadVehicleJsonQueue = dispatch_queue_create("com.abstractedsheep.jsonqueue", NULL);
	}
    
    dispatch_async(loadVehicleJsonQueue, ^{
        if ([vehiclesJsonParser parseShuttles]) {
            [self performSelectorOnMainThread:@selector(vehicleJsonRefresh) withObject:nil waitUntilDone:YES];
        }
    });
    
}

- (void)updateVehicleDataWithInterval:(CGFloat)secs {
	if (!loadVehicleJsonQueue) {
		loadVehicleJsonQueue = dispatch_queue_create("com.abstractedsheep.jsonqueue", NULL);
	}
    
    dispatch_async(loadVehicleJsonQueue, ^{
        if ([vehiclesJsonParser parseShuttles]) {
            [self performSelectorOnMainThread:@selector(vehicleJsonRefresh) withObject:nil waitUntilDone:YES];
        }
    });
}

- (void)vehicleJsonRefresh {
    BOOL alreadyAdded = NO;
    
    for (JSONVehicle *newVehicle in vehiclesJsonParser.vehicles) {
		alreadyAdded = NO;
		
        for (JSONVehicle *existingVehicle in vehicles) {
            if ([existingVehicle.name isEqualToString:newVehicle.name]) {
				[existingVehicle copyAttributesExceptLocation:newVehicle];
				
                [UIView animateWithDuration:0.5 animations:^{
                    [existingVehicle setCoordinate:newVehicle.coordinate];
                }];
                
                alreadyAdded = YES;
            }
        }
        
        if (!alreadyAdded) {
            [vehicles addObject:newVehicle];
        }
    }
	
	NSMutableArray *vehiclesToRemove = [[NSMutableArray alloc] init];
	
	for (JSONVehicle *vehicle in vehicles) {
		//	Remove vehicles which have not been updated for three minutes
		if ([vehicle.updateTime timeIntervalSinceNow] < -180.0f) {
			[vehiclesToRemove addObject:vehicle];
		}
	}
	
	for (JSONVehicle *vehicle in vehiclesToRemove) {
		[vehicles removeObject:vehicle];
	}
	
	[vehiclesToRemove release];
}


- (void)updateEtaData {
    
	if (!loadEtaJsonQueue) {
		loadEtaJsonQueue = dispatch_queue_create("com.abstractedsheep.jsonqueue", NULL);
	}
	
    dispatch_async(loadEtaJsonQueue, ^{
        if ([etasJsonParser parseEtas]) {
            [self performSelectorOnMainThread:@selector(etaJsonRefresh) withObject:nil waitUntilDone:YES];
        }
    });
    
}

- (void)etaJsonRefresh {
    [etas release];
    etas = [etasJsonParser.etas copy];
    
    westEtas = 0;
    eastEtas = 0;
    
    for (EtaWrapper *eta in etas) {
        if (eta.route == 1) {
            westEtas++;
        } else if (eta.route == 2) {
            eastEtas++;
        }
    }
    
    for (EtaWrapper *eta in etas) {
        for (KMLStop *stop in stops) {
            if (NULL) {
                //None
            }
        }
    }
}

- (void)setTimeDisplayFormatter:(NSDateFormatter *)newTimeDisplayFormatter {
	timeDisplayFormatter = newTimeDisplayFormatter;
	
	vehiclesJsonParser.timeDisplayFormatter = timeDisplayFormatter;
}


@end