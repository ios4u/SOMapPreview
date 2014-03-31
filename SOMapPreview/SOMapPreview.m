//
//  Created by Alex Evers on 3/26/2014.
//  Copyright ©2013-2014 under GNU General Public License (http://www.gnu.org/licenses/gpl.html)
//  Tab Size 8
//

#import "UIImage+MapRendering.h"

#import "SOMapPreview.h"

@interface SOMapPreview ()

@property (nonatomic, strong) CALayer *placeholderLayer;
@property (nonatomic, strong) UIImage *cachedImage;
@property (nonatomic, strong) NSString *cachePath;
@property (nonatomic, strong) SOAnimationSequence *animations;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

- (NSUInteger)hashForPolyline:(MKPolyline *)polyline;
- (BOOL)animateInMapImage:(UIImage *)image;

@end

@implementation SOMapPreview

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		/* Basic init */
		self.contentMode = UIViewContentModeScaleAspectFit;
		self.backgroundColor = [UIColor whiteColor];
		self.clipsToBounds = YES;

		/* Setup config defaults */
		self.cacheDirectory = NSTemporaryDirectory();
		self.routeColor = [UIColor blueColor];

		self.mapType = MKMapTypeStandard;
		self.showsBuildings = NO;
		self.showsPOI = NO;

		self.greyscale = YES;
		self.bordered = YES;
		self.roundedImage = YES;

		/* TODO add drop-in replacement for activityView */
		self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_activityView.color = [UIColor blackColor];
		_activityView.hidesWhenStopped = YES;
		_activityView.frame = CGRectMake(CGRectGetMidX(self.bounds)/2,
						 CGRectGetMidY(self.bounds)/2,
						 CGRectGetMidX(self.bounds),
						 CGRectGetMidY(self.bounds));
		[self addSubview:_activityView];

		/* CALayer containing placeholder content such as a static image */
		self.placeholderLayer = [CALayer layer];
		_placeholderLayer.frame = self.bounds;
	}
	return self;
}

#pragma mark - Top-level work methods

- (BOOL)previewCurrentLocation
{
	return YES;
}

#pragma mark - Set custom parameters

- (void)setBordered:(BOOL)bordered
{
	self.layer.borderWidth = bordered? 0.3f : 0;
}

- (void)setRoundedImage:(BOOL)rounded
{
	self.layer.cornerRadius = rounded ? CGRectGetWidth(self.frame) / 2 : 0;
}

- (void)setPlaceholderImage:(UIImage *)placeholder
{
	self.placeholderLayer.contents = (id)placeholder.CGImage;

	if (!_cachedImage)
		[self.layer addSublayer:_placeholderLayer];
}

- (void)setCacheDirectory:(NSString *)directory
{
	if (!directory || directory.length <= 0)
		return;

	BOOL is_dir;
	if ([directory characterAtIndex:0] == '~')
		directory = [directory stringByExpandingTildeInPath];

	if ([[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&is_dir])
		_cacheDirectory = directory;
}

- (BOOL)setDisabled
{
	self.image = nil;
	[self.layer addSublayer:_placeholderLayer];

	return YES;
}

#pragma mark - Lifecycle

- (NSUInteger)hashForPolyline:(MKPolyline *)polyline
{
	NSUInteger hash = 0;
	for (int x = 0; x < polyline.pointCount; x++)
	{
		MKMapPoint point = polyline.points[x];
		hash += point.x * point.y;
	}
	hash += (int)_greyscale + (int)_showsBuildings + (int)_showsPOI;
	return hash;
}

- (BOOL)loadCache:(MKPolyline *)polyline
{
	if (!polyline)
		return NO;

	[self addSubview:self.activityView];
	[_activityView startAnimating];

	if (self.cachedImage)
	{
		[self animateInMapImage:self.cachedImage];
		return YES;
	}

	self.cachePath = [NSString stringWithFormat:@"%@/map-preview-%d-cache.png", _cacheDirectory, [self hashForPolyline:polyline]];

	if ([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath])
	{
		[self animateInMapImage:[UIImage imageWithContentsOfFile:self.cachePath]];
		return YES;
	}

	return NO;
}

- (BOOL)renderPolylineOnMap:(MKPolyline *)polyline
{
	static dispatch_once_t setupItems;
	static dispatch_semaphore_t multiQueueSema;
	static dispatch_queue_t waitQueue, continueQueue;

	/* Init the semaphore, queues, and map */
	dispatch_once(&setupItems, ^{

		multiQueueSema = dispatch_semaphore_create(4);
		waitQueue = dispatch_queue_create("waitForMapRenderQueue", DISPATCH_QUEUE_SERIAL);
		continueQueue = dispatch_queue_create("continueMapRenderQueue", DISPATCH_QUEUE_SERIAL);
	});

	__weak typeof(self) wself = self;
	dispatch_async(waitQueue, ^{

		/* If we can load from file, skip the queue */
		if ([wself loadCache:polyline])
			return;

		dispatch_async(dispatch_get_main_queue(), ^{
			/* Show the user that this object in queue to be loaded */
			[wself.activityView startAnimating];
		});

		/* Wait for prior dispatches to do finish using the MKMapView */
		dispatch_semaphore_wait(multiQueueSema, DISPATCH_TIME_FOREVER);

		MKMapSnapshotOptions *options = [MKMapSnapshotOptions new];
		options.mapType = _mapType;
		options.showsBuildings = _showsBuildings;
		options.showsPointsOfInterest = _showsPOI;
		options.size = CGSizeMake(CGRectGetWidth(self.bounds) * 2, CGRectGetHeight(self.bounds) * 2);

		if (polyline)
		{
			MKCoordinateRegion region = MKCoordinateRegionForMapRect([polyline boundingMapRect]);
			region.span.latitudeDelta  *= 1.5f;
    			region.span.longitudeDelta *= 1.5f;
    			options.region = region;
		}
		else
			options.region = MKCoordinateRegionForMapRect(MKMapRectWorld);

		MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
		[snapshotter startWithQueue:continueQueue completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {

			dispatch_semaphore_signal(multiQueueSema);

			if (error)
				NSLog(@"An error occurred snapshooting the preview map: %@", error);
			else
			{
				UIImage *newImage = snapshot.image;
				if (wself.isGreyscale)
					newImage = [newImage convertToGreyscale];
				newImage = [newImage drawOverlay:polyline snapshot:snapshot];

				[wself animateInMapImage:newImage];
				[UIImagePNGRepresentation(newImage) writeToFile:wself.cachePath atomically:YES];
			}
		}];
	});

	return YES;
}

// Equivalent of setEnabled
- (BOOL)animateInMapImage:(UIImage *)image
{
	/* FIXME enqueue rather than discard */
	if (_animations)
		return NO;

	if (self.isRoundedImage)
		[image applyCircularMask:self.layer withRadius:CGRectGetWidth(self.bounds) / 2];

	[_placeholderLayer removeFromSuperlayer];

	__weak typeof(self) wself = self;
	self.animations = [[SOAnimationSequence alloc] initWithSequence:@[
			^{
				wself.image = nil;
				[wself.activityView removeFromSuperview];
			},
			^{ wself.image = image; },
			^(BOOL finished) {
				wself.cachedImage = image;
				wself.animations = nil;
			}
		]];
	_animations.target = self;
	_animations.treatFinalAsCompletion = YES;
	_animations.transitionDefault = UIViewAnimationOptionTransitionCrossDissolve;
	[_animations perform];

	return YES;
}

@end