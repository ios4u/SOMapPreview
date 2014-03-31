//
//  Created by Alex Evers on 3/26/2014.
//  Copyright ©2013-2014 under GNU General Public License (http://www.gnu.org/licenses/gpl.html)
//  Tab Size 8
//

#import <MapKit/MapKit.h>

@interface UIImage (MapRendering)

/** */
- (CGRect)rectFromMapRect:(MKMapRect)rect;

/** */
- (void)applyCircularMask:(CALayer *)layer withRadius:(CGFloat)radius;

/** */
- (UIImage *)drawLineWithPoints:(CGPoint *)coordSet pointCount:(NSUInteger)count rect:(CGRect)rect;

/** */
- (UIImage *)drawOverlay:(MKPolyline *)polyline snapshot:(MKMapSnapshot *)snap;

/** */
- (UIImage *)convertToGreyscale;

@end