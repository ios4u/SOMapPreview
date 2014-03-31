//
//  Created by Alex Evers on 3/26/2014.
//  Copyright ©2013-2014 under GNU General Public License (http://www.gnu.org/licenses/gpl.html)
//  Tab Size 8
//

#import "UIImage+MapRendering.h"

@implementation UIImage (MapRendering)

// included for convenient use below
- (CGRect)rectFromMapRect:(MKMapRect)rect
{
	return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)applyCircularMask:(CALayer *)layer withRadius:(CGFloat)radius
{
	CAShapeLayer *mask = [CAShapeLayer layer];
	mask.frame = layer.bounds;

	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddEllipseInRect(path, NULL, layer.bounds);
	[mask setPath:path];
	CGPathRelease(path);

	layer.mask = mask;
}

- (UIImage *)drawOverlay:(MKPolyline *)polyline snapshot:(MKMapSnapshot *)snap
{
	CLLocationCoordinate2D coord[polyline.pointCount];
	CGPoint points[polyline.pointCount];

	[polyline getCoordinates:coord range:NSMakeRange(0,polyline.pointCount)];
	for (int x = 0; x < polyline.pointCount; x++)
		points[x] = [snap pointForCoordinate:coord[x]];

	CGRect rect = [self rectFromMapRect:[polyline boundingMapRect]];

	return [self drawLineWithPoints:points pointCount:polyline.pointCount rect:rect];
}

- (UIImage *)drawLineWithPoints:(CGPoint *)coordSet pointCount:(NSUInteger)count rect:(CGRect)rect
{
	// begin a graphics context of sufficient size
	UIGraphicsBeginImageContext(self.size);

	// draw original image into the context
	[self drawAtPoint:CGPointZero];

	// get the context for CoreGraphics
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	[[UIColor blueColor] setStroke];
	UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];

	[path moveToPoint:coordSet[0]];

	for (int x = 1; x < count; x++)
		[path addLineToPoint:coordSet[x]];

	path.lineWidth = 8.0f;
	[path stroke];

	CGContextAddPath(ctx, path.CGPath);

	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();

	// free the context
	UIGraphicsEndImageContext();

	return retImage;
}

// Mostly taken from a stackoverflow post
- (UIImage *)convertToGreyscale
{
	int kRed = 1;
	int kGreen = 2;
	int kBlue = 4;

	int colors = kGreen;
	int m_width = self.size.width;
	int m_height = self.size.height;

	uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGContextSetShouldAntialias(context, NO);
	CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [self CGImage]);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);

	// now convert to grayscale
	uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
	for(int y = 0; y < m_height; y++)
	{
		for(int x = 0; x < m_width; x++)
		{
			uint32_t rgbPixel=rgbImage[y*m_width+x];
			uint32_t sum=0,count=0;
			if (colors & kRed) {sum += (rgbPixel >> 24) & 255; count++;}
			if (colors & kGreen) {sum += (rgbPixel >> 16) & 255; count++;}
			if (colors & kBlue) {sum += (rgbPixel >> 8) & 255; count++;}
			m_imageData[y*m_width+x]=sum/count;
		}
	}
	free(rgbImage);

	// convert from a gray scale image back into a UIImage
	uint8_t *result = (uint8_t *) calloc(m_width * m_height *sizeof(uint32_t), 1);

	// process the image back to rgb
	for(int i = 0; i < m_height * m_width; i++)
	{
		result[i*4]=0;
		int val=m_imageData[i];
		result[i*4+1]=val;
		result[i*4+2]=val;
		result[i*4+3]=val;
	}

	// create a UIImage
	colorSpace = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate(result, m_width, m_height, 8, m_width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	UIImage *resultUIImage = [UIImage imageWithCGImage:image];
	CGImageRelease(image);

	free(m_imageData);

	// make sure the data will be released by giving it to an autoreleased NSData
	[NSData dataWithBytesNoCopy:result length:m_width * m_height];

	return resultUIImage;
}

@end