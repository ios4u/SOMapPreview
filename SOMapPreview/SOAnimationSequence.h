
@interface SOAnimationSequence : NSObject

typedef void (^BOOLBlock)(BOOL finished);

@property (nonatomic, weak) UIView *target;
@property (nonatomic, assign) BOOL treatFinalAsCompletion;
@property (nonatomic, assign) UIViewAnimationOptions transitionDefault;

- (SOAnimationSequence *)initWithSequence:(NSArray *)sequence;
- (void)perform;

@end