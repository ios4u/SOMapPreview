//
//  Created by Alex Evers on 3/26/2014.
//  Copyright ©2013-2014 under GNU General Public License (http://www.gnu.org/licenses/gpl.html)
//  Tab Size 8
//
#import "SOCollectionViewCell.h"

@interface SOCollectionViewCell ()

@property (nonatomic, strong) SOMapPreview *mapPreview;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SOCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
		self.clipsToBounds = YES;
		self.layer.cornerRadius = CGRectGetWidth(frame)/10;

		self.mapPreview = [[SOMapPreview alloc] initWithFrame:frame];
		_mapPreview.translatesAutoresizingMaskIntoConstraints = NO;
		[_mapPreview setPlaceholderImage:[UIImage imageNamed:@"placeholder"]];
		[self addSubview:_mapPreview];

		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-20, self.bounds.size.width, 20)];
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		self.titleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];

		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapPreview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mapPreview)]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mapPreview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mapPreview)]];
	}
	return self;
}

- (void)setTitle:(NSString *)title
{
	if (!title)
		[_titleLabel removeFromSuperview];

	_titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{
						NSForegroundColorAttributeName: [UIColor whiteColor],
						NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:14]
					}];
	[self addSubview:_titleLabel];
}

- (void)loadFrom:(CLLocationCoordinate2D)fromCoordinate
	      to:(CLLocationCoordinate2D)toCoordinate
{
	MKDirectionsRequest *request = [MKDirectionsRequest new];

	MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate addressDictionary:nil];
	MKMapItem *sourceItem = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];

	MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:toCoordinate addressDictionary:nil];
	MKMapItem *destinationItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];

	request.source = sourceItem;
	request.destination = destinationItem;
	request.requestsAlternateRoutes = NO;
	request.transportType = MKDirectionsTransportTypeAutomobile;
	request.departureDate = [NSDate date];

	MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

	__weak typeof(self) wself = self;
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {

		MKRoute *route = [response.routes lastObject];
		MKPolyline *polyline = [route polyline];
		[wself.mapPreview renderPolylineOnMap:polyline];
	}];
}

@end
