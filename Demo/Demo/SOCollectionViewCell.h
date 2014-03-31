//
//  Created by Alex Evers on 3/26/2014.
//  Copyright ©2013-2014 under GNU General Public License (http://www.gnu.org/licenses/gpl.html)
//  Tab Size 8
//

#import <MapKit/MapKit.h>
#import "SOMapPreview.h"

@interface SOCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) SOMapPreview *mapPreview;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

- (void)setTitle:(NSString *)title;
- (void)loadFrom:(CLLocationCoordinate2D)fromCoordinate to:(CLLocationCoordinate2D)toCoordinate;

@end
