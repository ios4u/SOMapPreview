//
//  Created by Alex Evers on 3/26/2014.
//  Copyright ©2013-2014 under GNU General Public License (http://www.gnu.org/licenses/gpl.html)
//  Tab Size 8
//

#import <MapKit/MapKit.h>
#import "SOAnimationSequence.h"

@interface SOMapPreview : UIImageView

@property (nonatomic, strong, readonly) UIImage *cachedImage;
@property (nonatomic, strong, readonly) NSString *cachePath;

@property (nonatomic, strong) NSString *cacheDirectory;
@property (nonatomic, strong) UIColor *routeColor;

@property (nonatomic, assign, getter=isGreyscale) BOOL greyscale;
@property (nonatomic, assign, getter=isBordered) BOOL bordered;
@property (nonatomic, assign, getter=isRoundedImage) BOOL roundedImage;
@property (nonatomic, assign) BOOL showsBuildings;
@property (nonatomic, assign) BOOL showsPOI;
@property (nonatomic, assign) MKMapType mapType;

/** */
- (BOOL)previewCurrentLocation;

/** */
- (void)setPlaceholderImage:(UIImage *)placeholder;

/** */
- (BOOL)setDisabled;

/** */
- (BOOL)loadCache:(MKPolyline *)polyline;

/** */
- (BOOL)renderPolylineOnMap:(MKPolyline *)polyline;

@end