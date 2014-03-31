//
//  Created by Alex Evers on 3/26/2014.
//  Copyright ©2013-2014 under GNU General Public License (http://www.gnu.org/licenses/gpl.html)
//  Tab Size 8
//

#import <UIKit/UIKit.h>
#import "SOCollectionViewCell.h"

@interface SOViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *selectModeControl;

@end
