#import <UIKit/UIKit.h>

typedef enum {
    KVNDrawingToolTypePen,
    KVNDrawingToolTypeLine,
    KVNDrawingToolTypeArrow,
    KVNDrawingToolTypeRectangleStroke,
    KVNDrawingToolTypeRectangleFill,
    KVNDrawingToolTypeEllipseStroke,
    KVNDrawingToolTypeEllipseFill,
    KVNDrawingToolTypeEraser,
    KVNDrawingToolTypeText,
    KVNDrawingToolTypeMultilineText,
    KVNDrawingToolTypeCustom,
} KVNDrawingToolType;

typedef NS_ENUM(NSUInteger, KVNDrawingMode) {
    KVNDrawingModeScale,
    KVNDrawingModeOriginalSize
};

@protocol KVNDrawingViewDelegate, KVNDrawingTool;

@interface KVNDrawingView : UIView<UITextViewDelegate>

@property (nonatomic, assign) KVNDrawingToolType drawTool;
@property (nonatomic, strong) id<KVNDrawingTool> customDrawTool;
@property (nonatomic, assign) id<KVNDrawingViewDelegate> delegate;

// public properties
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineAlpha;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) KVNDrawingMode drawMode;

// get the current drawing
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, readonly) NSUInteger undoSteps;

// load external image
- (void)loadImage:(UIImage *)image;
- (void)loadImageData:(NSData *)imageData;

// erase all
- (void)clear;

// undo / redo
- (BOOL)canUndo;
- (void)undoLatestStep;

- (BOOL)canRedo;
- (void)redoLatestStep;

/**
 @discussion Discards the tool stack and renders them to prev_image, making the current state the 'start' state.
 (Can be called before resize to make content more predictable)
 */
- (void)commitAndDiscardToolStack;

@end

#pragma mark -

@protocol KVNDrawingViewDelegate <NSObject>

@optional
- (void)drawingView:(KVNDrawingView *)view willBeginDrawUsingTool:(id<KVNDrawingTool>)tool;
- (void)drawingView:(KVNDrawingView *)view didEndDrawUsingTool:(id<KVNDrawingTool>)tool;

@end
