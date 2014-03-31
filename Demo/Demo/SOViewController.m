//
//  Created by Alex Evers on 3/26/2014.
//  Copyright ©2013-2014 under GNU General Public License (http://www.gnu.org/licenses/gpl.html)
//  Tab Size 8
//

#import "SOViewController.h"

@interface SOViewController ()

@property (nonatomic, strong) NSArray *mapPreviewItems;

@end

@implementation SOViewController

- (void)loadView
{
	[super loadView];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
	label.backgroundColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.attributedText = [[NSAttributedString alloc] initWithString:@"Going to Apple HQ" attributes:@{
					NSForegroundColorAttributeName: [UIColor blackColor],
					NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
					}];
	[self.view addSubview:label];
}

- (void)viewDidLoad
{
	self.mapPreviewItems = @[
			/* from (lat, lng) -> to (lat, lng) */
			@[@(37.77082), @(-122.41089), @(37.33174), @(-122.03033), @"Costco"], // costco -> apple
			@[@(37.32320), @(-122.03808), @(37.33174), @(-122.03033), @"Panera"], // panera -> apple
			@[@(37.48338), @(-122.14955), @(37.33174), @(-122.03033), @"Facebook"], // facebook -> apple
			@[@(37.32270), @(-121.96344), @(37.33174), @(-122.03033), @"Barnes & Nobles"], // barnes&nobles -> apple
			@[@(37.61522), @(-122.38998), @(37.33174), @(-122.03033), @"Sfo"], // sfo -> apple
			@[@(38.58157), @(-121.49440), @(37.33174), @(-122.03033), @"Sacramento"], // sacramento -> apple
		];

	[self.collectionView registerClass:[SOCollectionViewCell class] forCellWithReuseIdentifier:@"SourceCellKind"];
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"header"];
	self.collectionView.contentInset = UIEdgeInsetsMake(50,0,0,0);
	[super viewDidLoad];
}

#pragma mark - UICollectionView

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	SOCollectionViewCell *source_cell = [cv dequeueReusableCellWithReuseIdentifier:@"SourceCellKind" forIndexPath:indexPath];

	NSArray *item = _mapPreviewItems[indexPath.row];

	CLLocationCoordinate2D fromCoord = CLLocationCoordinate2DMake([item[0] doubleValue], [item[1] doubleValue]);
	CLLocationCoordinate2D toCoord = CLLocationCoordinate2DMake([item[2] doubleValue], [item[3] doubleValue]);

	if (indexPath.section == 0)
	{
		source_cell.mapPreview.greyscale = NO;
		source_cell.mapPreview.mapType = MKMapTypeHybrid;
	}

	[source_cell loadFrom:fromCoord to:toCoord];
	[source_cell setTitle:item[4]];

	return source_cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if (kind != UICollectionElementKindSectionHeader)
		return nil;

	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"header" forIndexPath:indexPath];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-10, -40, 330, 40)];
	label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7f];
	label.textAlignment = NSTextAlignmentCenter;

	NSString *title = nil;
	if (indexPath.section == 0)
		title = @"Hybrid map with color";
	else
		title = @"Standard map with greyscale color";

	label.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{
					NSForegroundColorAttributeName: [UIColor blueColor],
					NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16]
					}];

	[cell.contentView addSubview:label];

	return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
			layout:(UICollectionViewLayout*)collectionViewLayout
	insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsMake(5,5,5,5);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [_mapPreviewItems count];
}

@end
