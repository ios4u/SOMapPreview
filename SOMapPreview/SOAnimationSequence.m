

#import "SOAnimationSequence.h"

@interface SOAnimationSequence ()

@property (nonatomic, strong) NSArray *sequence;

- (void)performIndex:(NSUInteger)index;

@end

@implementation SOAnimationSequence

- (SOAnimationSequence *)initWithSequence:(NSArray *)sequence
{
	self = [super init];
	if (self)
	{
		self.sequence = sequence;
		self.transitionDefault = UIViewAnimationOptionCurveEaseInOut;
	}
	return self;
}

- (void)perform
{
	if (self.sequence)
	{
		__weak typeof(self) wself = self;
		dispatch_async(dispatch_get_main_queue(), ^{
			[wself performIndex:0];
		});
	}
}

- (void)performIndex:(NSUInteger)index
{
	if (!_target)
		return;

	__weak typeof(self) wself = self;
	[UIView transitionWithView:_target duration:0.3f options:wself.transitionDefault
		animations:wself.sequence[index]
		completion:^(BOOL finished) {
			if (wself.sequence.count > index + 1)
				[wself performIndex:index + 1];
		}];
}

@end
